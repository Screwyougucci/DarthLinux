# Darth Linux Mobile build status

## Current stage: M1 CI build complete; M2 non-destructive boot preparation

This branch now has:
- A first dependency-light C framebuffer launcher prototype in `ui/`.
- Host compile and renderer self-tests in GitHub Actions.
- AArch64 cross-compilation with 16 KiB ELF alignment validation.
- A pinned N112 Buildroot build path using the Sandcastle kernel, device tree, and HX utilities.
- A successful full CI build of the ARM64 kernel Image, N112 DTB, and compressed initramfs (workflow #48).
- A successful SHA-256 verification of every published build component and its revision/configuration manifests (workflow #48).
- A Buildroot package and init script that launch the framebuffer UI after HX touch setup.
- A post-build check that locks the root account and rejects Dropbear startup.
- A read-only device diagnostic command (darth-hwcheck) for framebuffer, input, GPU/DRM, audio, camera, mounts, and kernel logs.
- A verified, local-only extractor for the N112.mtprops file from the official iOS 15.8.8 IPSW; it uses HTTP range requests and does not publish the proprietary firmware.
- A separate mobile-only build entry point.
- A Linux host dependency check.
- Explicit source-directory checks for Project Sandcastle and Buildroot.
- Exact upstream source revisions recorded in `UPSTREAM_PINS.md`.

## Blocking engineering inputs

The UI source, device-specific Buildroot integration, and N112 firmware extraction path are committed. The full N112 CI build and artifact SHA-256 verification both passed in workflow #48. The public artifact contains the kernel Image, N112 DTB, compressed initramfs, Buildroot configuration, upstream revision record, and SHA256SUMS manifest. This is a set of Sandcastle boot components, not a single flashable image. The extracted N112.mtprops firmware is still local-only and is not yet integrated into the public CI initramfs; that private build integration and all shell/touchscreen behavior still need validation on the actual iPod.

The pinned source revisions and N112 device tree/kernel configuration are recorded in `UPSTREAM_PINS.md`. The build uses the upstream HX touch driver and hx-touchd firmware path. A known m4/glibc host-build compatibility patch is included. GPU acceleration, audio, and camera remain separate driver-development blockers.

The upstream Sandcastle documentation describes a Buildroot-based ramdisk and a loader that passes the kernel and device tree through pongoOS. The successful CI run is [#48](https://github.com/Screwyougucci/DarthLinux/actions/runs/42503272470); its artifacts are available from that run until 2027-02-06. See:
- https://projectsandcastle.org/status
- https://github.com/corellium/projectsandcastle
- https://github.com/corellium/linux-sandcastle
- https://github.com/corellium/sandcastle-buildroot

## Safety boundary

CI and local build scripts must never run device flashing, NAND writes, APFS writes, repartitioning, or bootloader modification. The first deliverable is a reproducible rootfs/build artifact and a documented, non-destructive boot test plan—not an iOS replacement installer.
