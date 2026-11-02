# Darth Driver Manager 0.2 — Hardware Support Plan

**Project:** Darth Linux  
**Target release:** 0.2 — The Security Awakening  
**Status:** Planning specification only — not implemented

## Purpose

Darth Driver Manager is a proposed graphical utility for detecting hardware, reporting driver and firmware status, helping users diagnose missing devices, and guiding safe driver installation. It should make hardware support understandable without promising that every device is supported.

## Existing foundation

The current package profile includes the Linux kernel, `linux-firmware`, NetworkManager, Bluetooth management through Blueman, PipeWire audio, Video4Linux utilities, brightness controls, and libinput-based desktop input support through the graphical stack. These provide a useful baseline, but do not prove compatibility with every laptop or peripheral.

## Planned interface

### 1. Hardware overview

Show detected devices grouped by category:

- Graphics and display adapters
- Wi-Fi and Ethernet network adapters
- Bluetooth controllers
- Audio controllers and devices
- Touchpads, keyboards, and pointing devices
- Printers and scanners
- Cameras and video devices
- Storage controllers and removable USB devices
- Power and battery devices

For each device, show its vendor/model or hardware ID when available, currently bound kernel driver, firmware status when detectable, and whether a reboot may be needed.

### 2. Driver and firmware status

- Identify devices with no bound driver or a reported initialization error.
- Show whether the driver is built into the kernel, supplied as a kernel module, or provided by a userspace component.
- Detect firmware-loading errors from local system logs where permitted.
- Explain the difference between a driver and firmware.
- Link each suggested package to its trusted distribution source and show its package name before installation.
- Never claim a device is unsupported based only on an incomplete hardware database.

### 3. Graphics support

Provide detection and guidance for:

- Intel integrated graphics using the kernel driver and Mesa userspace stack.
- AMD graphics using the kernel driver and Mesa userspace stack.
- NVIDIA hardware, explaining the available open or proprietary driver choices and hardware/kernel compatibility considerations.

Do not install multiple conflicting graphics driver stacks automatically. Explain trade-offs, verify package provenance, and require confirmation before changing graphics drivers. Preserve a recovery path if a driver change prevents the graphical desktop from starting.

### 4. Wi-Fi and Bluetooth troubleshooting

- Display adapter model, kernel driver, interface state, and NetworkManager status.
- Surface relevant firmware errors and blocked-radio status where available.
- Offer safe diagnostic steps such as checking service state and listing nearby networks only when the user requests it.
- Show Bluetooth controller state and service status.
- Do not collect or upload network names, MAC addresses, or nearby-device details.

### 5. Printers, audio, touchpads, and USB

- Printer/scanner support guidance through the appropriate CUPS and scanning components when selected.
- Audio device visibility and PipeWire status checks.
- Touchpad and input-device status using the Linux input stack.
- USB device inventory and mount-state information.
- Avoid automatically mounting unknown filesystems with elevated privileges or executing content from removable media.

## Driver installation safety

- Prefer official Arch repositories and signed packages.
- Do not download random driver installers or execute vendor scripts from the internet.
- Show the exact package, source repository, size, dependencies, and proposed changes before installation.
- Require explicit user confirmation for privileged changes.
- Create or verify a recovery option before high-impact graphics or kernel changes.
- Record installation and removal actions in a local log.
- Support removal or rollback where the package manager and driver design make it safe.
- Never disable Secure Boot, signature verification, or kernel protections silently.
- Do not promise that every third-party driver is open source or compatible.

## Low-resource and offline behavior

- Keep hardware inventory lightweight and on demand where possible.
- Do not continuously poll every device.
- Cache local hardware information with a refresh option.
- Core inventory and diagnostics should work offline.
- Internet access is only needed to retrieve package metadata or install updates.
- No hidden telemetry or hardware fingerprint uploads.

## Integration

- **Command Center:** show hardware health and driver warnings.
- **Darth Settings:** link to relevant display, audio, network, and input settings.
- **Darth Store:** install only verified packages from configured trusted sources.
- **Watchtower:** optionally record driver errors and hardware-related events without exposing unnecessary device identifiers.
- **Darth Recovery:** provide guidance for recovering from failed graphics or kernel driver changes.

## Proposed acceptance tests

- [ ] Detect and classify common PCI and USB devices.
- [ ] Show the active kernel driver for supported devices.
- [ ] Report missing firmware when the system logs provide evidence.
- [ ] Correctly distinguish unknown hardware from confirmed missing-driver cases.
- [ ] Detect Intel, AMD, and NVIDIA graphics hardware and show appropriate guidance.
- [ ] Do not automatically install conflicting graphics driver packages.
- [ ] Verify package signatures and trusted repository origin before installation.
- [ ] Require confirmation before privileged package changes.
- [ ] Test Wi-Fi, Ethernet, Bluetooth, audio, touchpad, webcam, printer, and USB behavior on representative hardware.
- [ ] Test recovery after a deliberately failed driver configuration in a disposable VM or test machine.
- [ ] Confirm inventory and diagnostics work offline.
- [ ] Confirm low background CPU and memory use.
- [ ] Confirm no hardware inventory is transmitted as telemetry.

## Delivery status

This document is a release-planning specification. It does not implement a driver manager, install new drivers, or certify hardware compatibility. Hardware support must be validated on actual devices and documented test results before release claims are made.
