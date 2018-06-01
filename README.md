# kUSD Ledger application

kUSD wallet application framework for Ledger Blue and Nano S.

The application is essentially a fork of the [Ethereum application](https://github.com/LedgerHQ/blue-app-eth)
with a different derivation path and currency name.

## 1. Building the application

There are two ways of doing this: with Docker and without Docker. Building with Docker is significantly easier because the
[Kowala ledger image](https://hub.docker.com/r/kowalatech/ledger/) includes all the build dependencies, but either way will work.

### 1.1 With Docker

Mount the application directory and run `make` in the docker container: 

```
docker run -v `pwd`:/home/workspace kowalatech/ledger make
```

The binaries will be output to `bin/`.

### 1.2 Without Docker

1. Configure your development environment as outlined in the [official documentation](https://ledger.readthedocs.io/en/latest/userspace/getting_started.html).
2. Run `make`.

## 2. Loading the application onto a Nano S (or Blue) device:

If you're using Linux, then you can use docker for this as well. For other operating systems, you'll have to load manually.

### 2.1 Using Docker (Linux only)

Before proceeding, making sure you have the following udev rules added to `/etc/udev/rules.d`:

```
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0000", MODE="0660", TAG+="uaccess", TAG+="udev-acl" OWNER="<UNIX username>"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001", MODE="0660", TAG+="uaccess", TAG+="udev-acl" OWNER="<UNIX username>"
```

You can then load the software onto the device by mounting your current directory and the USB bus:

```
docker run --privileged \
       -v /dev/bus/usb:/dev/bus/usb \
       -v `pwd`:/home/workspace \ 
       kowalatech/ledger make load
```

Note that the device must be connected via USB and in the 'home' state (PIN entered and no application open).

### 2.1 Manual loading

1. Configure the python loader as described in the [documentation](https://github.com/LedgerHQ/blue-loader-python).
2. Run `make load`.

Note that the device must be connected via USB and in the 'home' state (PIN entered and no application open).

## 2. Use cases and testing

The kUSD application is designed run on a Ledger Nano S (and possibly Blue) as a hardware wallet for the following purposes:

1. To hold funds
2. To hold mining tokens (or `mtokens`; a Proof-of-Authority token)

In order to transfer mtokens, the `Contract Data` must be enabled in the settings.

The application can be tested on our [Zygote](http://zygote.kowala.io) testnet; please contact us for more details.

-----------------------------

Note: At the time of writing, the application has been tested on a Ledger Nano S, but not a Ledger Blue.
