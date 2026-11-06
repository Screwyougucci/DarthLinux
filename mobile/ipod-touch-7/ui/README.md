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

The self-test exercises the renderer's pixel-format and geometry helpers without
opening a framebuffer or input device. A successful host test is not evidence
that the iPod's framebuffer or touch controller works.

## Run on a Linux device

```sh
sudo ./darth-shell --fb /dev/fb0
sudo ./darth-shell --fb /dev/fb0 --input auto\n# Or explicitly select a verified event node:\nsudo ./darth-shell --fb /dev/fb0 --input /dev/input/eventX
```

The input event node is deliberately explicit. Identify it from read-only
`/proc/bus/input/devices` and `evtest`; do not guess an event number. The
prototype accepts single-touch ABS_X/ABS_Y + BTN_TOUCH input and maps the
reported axis ranges to the framebuffer. Device-specific axis inversion or
calibration may still be required.

## Current limitations

- Uses the kernel-provided framebuffer; no GPU driver or acceleration.
- Touch input uses the upstream HX multitouch evdev interface when the HX firmware daemon has initialized it.
- No audio, camera, Wi-Fi, installer, persistence, or AI code is included.
- It does not mount, write, or modify iOS/APFS/NAND storage.
- The prototype is not yet integrated into a bootable root filesystem.
