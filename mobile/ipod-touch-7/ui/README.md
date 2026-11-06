# Darth Mobile shell prototype

This is the first executable UI component for the iPod touch 7 bring-up branch.
It is a small C program with no third-party runtime dependency. It draws a
Darth-themed launcher directly to Linux fbdev and can optionally read Linux
evdev touch events.

## Build and test on a Linux host

```sh
make
make test
```

The self-test exercises pixel-format packing and framebuffer bounds without
opening a framebuffer or input device. A successful host test is not evidence
that the iPod's framebuffer or touch controller works.

## Run on a Linux device

```sh
sudo ./darth-shell --fb /dev/fb0 --input auto
# Or explicitly select a verified event node:
sudo ./darth-shell --fb /dev/fb0 --input /dev/input/eventX
```

For the iPod target, auto mode searches for the upstream input device named
Hx Capacitive TouchScreen. It reads the ten-slot multitouch protocol:
ABS_MT_SLOT, ABS_MT_TRACKING_ID, and ABS_MT_POSITION_X/Y. A legacy
ABS_X/ABS_Y + BTN_TOUCH fallback remains for other devices. The hx-touchd
firmware daemon must initialize the controller first. Axis inversion or
calibration may still be required and must be validated on the actual device.

The launcher remains in the foreground. Use Ctrl+C or SIGTERM to exit. If no
touchscreen is found, it keeps displaying a static launcher.

## Current limitations

- Uses the kernel-provided framebuffer; no GPU driver or acceleration.
- Touch selection is experimental until validated on an iPod touch 7.
- No audio, camera, Wi-Fi settings, installer, persistence, or AI code is included.
- It does not mount, write, or modify iOS/APFS/NAND storage.
- The Buildroot package and startup service are present, but the N112 image
  still needs a successful build and real-device validation.
