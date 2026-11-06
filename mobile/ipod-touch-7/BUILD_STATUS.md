# Darth Linux Mobile build status

## Current stage: M1 device-specific N112 build integration

This branch now has:
- A first dependency-light C framebuffer launcher prototype in `ui/`.
- Host compile and renderer self-tests in GitHub Actions.
- AArch64 cross-compilation with 16 KiB ELF alignment validation.
- A pinned N112 Buildroot build path using the Sandcastle kernel, device tree, and HX utilities.
- A Buildroot package and init script that launch the framebuffer UI after HX touch setup.
- A post-build check that locks the root account and rejects Dropbear startup.
- A read-only device diagnostic command (darth-hwcheck) for framebuffer, input, GPU/DRM, audio, camera, mounts, and kernel logs.
- A verified, local-only extractor for the N112.mtprops file from the official iOS 15.8.8 IPSW; it uses HTTP range requests and does not publish the proprietary firmware.
- A separate mobile-only build entry point.
- A Linux host dependency check.
- Explicit source-directory checks for Project Sandcastle and Buildroot.
- Exact upstream source revisions recorded in `UPSTREAM_PINS.md`.

## Blocking engineering inputs

The UI source, device-specific Buildroot integration, and N112 firmware extraction path are committed. The firmware extraction check passed, but the full N112 image pipeline still needs a successful CI build. No bootable artifact is claimed until CI produces the kernel image, N112 DTB, and initramfs. The local firmware still needs to be wired into the initramfs build; the shell and touchscreen path still need real-device validation.

The pinned source revisions and N112 device tree/kernel configuration are recorded in `UPSTREAM_PINS.md`. The build uses the upstream HX touch driver and hx-touchd firmware path. A known m4/glibc host-build compatibility patch is included. GPU acceleration, audio, and camera remain separate driver-development blockers.

The upstream Sandcastle documentation describes a Buildroot-based ramdisk and a loader that passes the kernel and device tree through pongoOS. See:
- https://projectsandcastle.org/status
- https://github.com/corellium/projectsandcastle
- https://github.com/corellium/linux-sandcastle
- https://github.com/corellium/sandcastle-buildroot

## Safety boundary

CI and local build scripts must never run device flashing, NAND writes, APFS writes, repartitioning, or bootloader modification. The first deliverable is a reproducible rootfs/build artifact and a documented, non-destructive boot test plan—not an iOS replacement installer.
