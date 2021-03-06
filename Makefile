#*******************************************************************************
#   Ledger App
#   (c) 2017 Ledger
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#*******************************************************************************

CHAIN  ?= kusd
PYTHON ?= python

ifeq ($(BOLOS_SDK),)
$(error Environment variable BOLOS_SDK is not set)
endif
include $(BOLOS_SDK)/Makefile.defines

APPVERSION_M=1
APPVERSION_N=0
APPVERSION_P=22
APPVERSION=$(APPVERSION_M).$(APPVERSION_N).$(APPVERSION_P)

ifeq ($(CHAIN),ethereum)
APP_LOAD_PARAMS += --path "44'/60'" --path "44'/61'"
DEFINES += CHAINID_UPCASE=\"ETHEREUM\" CHAINID_COINNAME=\"ETH\" CHAINID_NAME=\"Ethereum\" CHAINID=$(CHAIN) CHAIN_TYPE_ETHEREUM
APPNAME = Ethereum
else ifeq ($(CHAIN),expanse)
APP_LOAD_PARAMS += --path "44'/40'"
DEFINES += CHAINID_UPCASE=\"EXPANSE\" CHAINID_COINNAME=\"EXP\" CHAINID_NAME=\"Expanse\" CHAINID=$(CHAIN) CHAIN_TYPE_EXPANSE
APPNAME = Expanse
else ifeq ($(CHAIN),ubiq)
APP_LOAD_PARAMS += --path "44'/108'"
DEFINES += CHAINID_UPCASE=\"UBIQ\" CHAINID_COINNAME=\"UBQ\" CHAINID_NAME=\"Ubiq\" CHAINID=$(CHAIN) CHAIN_TYPE_UBIQ
APPNAME = Ubiq
else ifeq ($(CHAIN),kusd)
APP_LOAD_PARAMS += --path "44'/91927009'"
DEFINES += CHAINID_UPCASE=\"KUSD\" CHAINID_COINNAME=\"kUSD\" CHAINID_NAME=\"kUSD\" CHAINID=$(CHAIN) CHAIN_TYPE_ETHEREUM
APPNAME = kUSD
else
ifeq ($(filter clean,$(MAKECMDGOALS)),)
$(error Unsupported CHAIN - use ethereum, expanse, ubiq)
endif
endif
APP_LOAD_PARAMS += --appFlags 0x40 --path "44'/1'" --curve secp256k1 $(COMMON_LOAD_PARAMS) 

#prepare hsm generation
ifeq ($(TARGET_NAME),TARGET_BLUE)
ICONNAME=blue_app_$(CHAIN).gif
else
ICONNAME=nanos_app_$(CHAIN).gif
endif

################
# Default rule #
################
all: default

############
# Platform #
############

DEFINES   += OS_IO_SEPROXYHAL IO_SEPROXYHAL_BUFFER_SIZE_B=128
DEFINES   += HAVE_BAGL HAVE_SPRINTF
#DEFINES   += HAVE_PRINTF PRINTF=screen_printf
DEFINES   += PRINTF\(...\)=
DEFINES   += HAVE_IO_USB HAVE_L4_USBLIB IO_USB_MAX_ENDPOINTS=6 IO_HID_EP_LENGTH=64 HAVE_USB_APDU
DEFINES   +=  LEDGER_MAJOR_VERSION=$(APPVERSION_M) LEDGER_MINOR_VERSION=$(APPVERSION_N) LEDGER_PATCH_VERSION=$(APPVERSION_P)

# U2F
DEFINES   += HAVE_U2F
DEFINES   += USB_SEGMENT_SIZE=64
DEFINES   += BLE_SEGMENT_SIZE=32 #max MTU, min 20
DEFINES   += U2F_MAX_MESSAGE_SIZE=264 #257+5+2
DEFINES   += UNUSED\(x\)=\(void\)x
DEFINES   += APPVERSION=\"$(APPVERSION)\"
DEFINES   += CX_COMPLIANCE_141

##############
#  Compiler  #
##############
#GCCPATH   := $(BOLOS_ENV)/gcc-arm-none-eabi-5_3-2016q1/bin/
#CLANGPATH := $(BOLOS_ENV)/clang-arm-fropi/bin/
CC       := $(CLANGPATH)clang 

#CFLAGS   += -O0
CFLAGS   += -O3 -Os -I/usr/include

AS     := $(GCCPATH)arm-none-eabi-gcc

LD       := $(GCCPATH)arm-none-eabi-gcc
LDFLAGS  += -O3 -Os
LDLIBS   += -lm -lgcc -lc 

# import rules to compile glyphs(/pone)
include $(BOLOS_SDK)/Makefile.glyphs

### computed variables
APP_SOURCE_PATH  += src_genericwallet src_common src 
SDK_SOURCE_PATH  += lib_stusb


load: all
	$(PYTHON) -m ledgerblue.loadApp $(APP_LOAD_PARAMS)

delete:
	$(PYTHON) -m ledgerblue.deleteApp $(COMMON_DELETE_PARAMS)

# import generic rules from the sdk
include $(BOLOS_SDK)/Makefile.rules

#add dependency on custom makefile filename
dep/%.d: %.c Makefile.genericwallet

