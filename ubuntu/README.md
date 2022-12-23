# Ubuntu-specific Files

## Input / Output Management

The `/etc/udev/rules.d/90-block-webcam-mic.rules` file may need to be updated based
on the output of `lsusb`. The `idVendor` and `idProduct` may need to be updated
on new systems.
