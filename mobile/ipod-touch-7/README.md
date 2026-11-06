# Darth Linux Mobile — iPod touch (7th generation)

**Status: research / bring-up branch. Not a flashable release.**

Target:
- Device: iPod touch (7th generation)
- Board identifier: N112 / iPod9,1
- SoC: Apple A10 (T8010 family)
- Reported firmware supplied for this project: iOS 15.8.8

## Project goal

**Mobile edition policy: no AI.** Darth Linux Mobile will not include Darth AI, an AI assistant, AI model downloads, model runtimes, or AI background services. This exclusion applies only to the mobile edition; the separate desktop Darth Linux project is unchanged.


Build a Darth-branded ARM64 Linux userspace and mobile experience for the iPod touch 7, using the existing Project Sandcastle Linux boot path and device support where possible.

The requested end state is to use Linux instead of iOS. That is **not currently established as a safe, permanent replacement**. The first engineering milestone is a temporary, non-destructive Linux boot and hardware validation. No installer may erase, repartition, overwrite, or modify the iOS/APFS installation.

## Verified upstream baseline

Project Sandcastle's official status page explicitly lists iPod touch 7 (7G) as a supported target and currently offers a Linux build. Its published feature matrix reports the following for iPod touch 7:

| Component | Published status |
|---|---|
| CPU | Supported |
| UART | Supported |
| USB | Supported |
| AIC | Supported |
| NAND | Supported |
| Display | Supported |
| Multitouch | Supported |
| GPU | Not supported |
| PMU | Supported |
| Audio | Not supported |
| WLAN | Supported |
| Bluetooth | Supported |
| Camera | Not supported |

These are upstream status claims, not Darth Linux test results. Re-test each feature on the actual device and record kernel logs and test evidence.

Sources:
- https://projectsandcastle.org/status
- https://github.com/corellium/projectsandcastle
- https://ios.cfw.guide/get-started/iPod-touch-%287th-generation%29.html

## Architecture decision

Do not assume the desktop Darth Archiso image can boot directly on this Apple device. Keep the desktop profile unchanged.

Initial mobile architecture:
1. Use the official Sandcastle Linux boot chain and its device-specific kernel/device tree/loader.
2. Build a minimal ARM64 root filesystem compatible with the upstream kernel and boot environment. Evaluate Buildroot first because Sandcastle documents its Linux ramdisk as Buildroot-based.
3. Add a Darth Mobile session and touch-first shell only after basic boot, display, touch, USB, Wi-Fi, and storage are verified.
4. Keep device-specific firmware and upstream components traceable to their original projects and licenses.
5. Produce checksummed, reproducible artifacts and publish a clear hardware-support matrix.

## Milestones

### M0 — Research and safeguards
- [x] Confirm official upstream iPod touch 7 target listing.
- [x] Record upstream hardware feature matrix.
- [x] Isolate work on the `mobile/ipod-touch-7` branch.
- [ ] Record exact device model/board identity from a read-only inventory.
- [ ] Review upstream Linux build, loader, kernel, device tree, and licensing.
- [ ] Document recovery path before any device-side test.

### M1 — Build environment
- [ ] Pin upstream source revisions and toolchain versions.
- [ ] Create ARM64 Buildroot configuration or compatible minimal rootfs.
- [ ] Add reproducible build scripts and dependency checks.
- [ ] Add artifact checksums and SBOM/license inventory.
- [ ] CI builds rootfs only; no device flashing in CI.

### M2 — Non-destructive boot
- [ ] Boot using the documented Sandcastle path without erasing or repartitioning storage.
- [ ] Capture boot log and kernel version.
- [ ] Verify display, touch, USB, WLAN, Bluetooth, NAND read access, CPU and thermal/power reporting.
- [ ] Explicitly mark GPU, audio, and camera unavailable unless independently implemented and tested.

### M3 — Darth Mobile interface
- [ ] Touch-first launcher and settings.
- [ ] Darth graphite/crimson theme, scalable typography, large touch targets.
- [ ] Terminal, file manager, network settings, system monitor.
- [ ] Optional security tools with safe defaults.
- [ ] No AI assistant, model runtime, model downloads, or AI background services.
- [ ] No background scanning, telemetry, or network services enabled by default.

### M4 — Release evaluation
- [ ] Reproducible build from documented sources.
- [ ] Boot and recovery test report.
- [ ] Hardware compatibility report with known limitations.
- [ ] Independent review of any proposed persistent installation method.
- [ ] Do not describe as an iOS replacement unless persistent boot, recovery, and update behavior are demonstrated safely.

## Non-negotiable safety rules

- No erase, restore, repartition, NAND write, APFS write, or bootloader modification in the initial milestones.
- Do not disable or remove the user's iOS recovery path.
- Do not ship a one-click installer or claim permanent replacement until a tested, reversible method exists.
- Back up the device before any future device-side experimentation.
- Never bundle Apple firmware images; users must obtain firmware through legitimate Apple channels.
- Do not claim compatibility based only on another A10 device. The exact target is iPod9,1 / N112.

## Current release state

There is no Darth Linux Mobile ISO/IMG/IPA or flashable package yet. This branch currently contains project planning and the verified upstream compatibility baseline only.
