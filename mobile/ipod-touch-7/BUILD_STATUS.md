# Darth Linux Mobile build status

## Current stage: M1 scaffolding

This branch now has:
- A separate mobile-only build entry point.
- A Linux host dependency check.
- Explicit source-directory checks for Project Sandcastle and Buildroot.
- A hard stop instead of silently building a generic, incompatible ARM64 image.

## Blocking engineering inputs

The actual iPod9,1 build must use the exact upstream kernel, device tree, loader, Buildroot external configuration, firmware handling, and required 16 KiB page-size ABI. These must be pinned to known revisions before a reproducible image can be claimed.

The upstream Sandcastle documentation describes a Buildroot-based ramdisk and a loader that passes the kernel and device tree through pongoOS. See:
- https://projectsandcastle.org/status
- https://github.com/corellium/projectsandcastle
- https://github.com/corellium/linux-sandcastle
- https://github.com/corellium/sandcastle-buildroot

## Safety boundary

CI and local build scripts must never run device flashing, NAND writes, APFS writes, repartitioning, or bootloader modification. The first deliverable is a reproducible rootfs/build artifact and a documented, non-destructive boot test plan—not an iOS replacement installer.
