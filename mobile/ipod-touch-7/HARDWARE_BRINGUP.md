# iPod touch 7 hardware bring-up: GPU, audio, camera

This document tracks engineering work to improve the iPod9,1 / N112 (Apple T8010) hardware support. It is a driver-development plan, not a claim that any of these devices currently work.

## Ground truth

Project Sandcastle's published matrix marks GPU, audio, and camera unsupported for this target. The Linux kernel A10 device-tree work establishes the platform and basic facilities, but a device-tree entry alone is not a peripheral driver. The A10 DTS work explicitly focuses on essentials such as SMP, UART, framebuffer handoff, watchdog, timer, pinctrl, and Apple AIC interrupts.

References:
- https://projectsandcastle.org/status
- https://github.com/corellium/linux-sandcastle
- https://github.com/corellium/projectsandcastle
- https://lists.openwall.net/linux-kernel/2024/09/15/104
- https://lore-kernel.gnuweeb.org/lkml/20240919161443.10340-12-towinchenmi%40gmail.com/T/

## Touchscreen — upstream path now integrated (not yet device-tested)

The pinned N112 device tree and HX kernel config provide a concrete input path:
- Device tree: hx-h9p-n112.dts declares the SPI device as compatible with hx,touch.
- Kernel driver: drivers/input/touchscreen/hx-touch.c registers Hx Capacitive TouchScreen and ten multitouch slots.
- Firmware helper: hx-touchd loads the N112.mtprops firmware from the upstream firmware list.
- The Darth shell now auto-detects that input device and reads ABS_MT_SLOT,
  ABS_MT_TRACKING_ID, and ABS_MT_POSITION_X/Y events.

The upstream hx-touchd service is included, but the N112.mtprops file must
be supplied locally. The upstream fstab requests an APFS mount, yet the pinned
kernel has no APFS filesystem driver and Buildroot disables FUSE, so Darth
removes that mount attempt rather than touching the iOS volume. A firmware
extraction helper reads the official IPSW by HTTP range requests and writes
the N112.mtprops file locally; it is not uploaded to public CI artifacts.
Without that file, touch initialization is skipped and the launcher runs in
static framebuffer mode. With it, the HX path is still source-level only:
touch coordinates, orientation, firmware loading, and actual taps require
physical iPod testing. See UPSTREAM_PINS.md and firmware-tools/README.md.

## Pinned-kernel source audit: GPU, audio, and camera

A source audit of the pinned Sandcastle 5.4 kernel and the N112 device tree did
not find an N112-specific GPU driver, audio codec/ASoC path, or camera/ISP
pipeline. The N112 DTS describes the HX MIPI-DSI display path and HX
touchscreen, but has no audio or camera endpoint nodes. The kernel tree contains
many generic GPU, audio, and media drivers for unrelated SoCs; their presence
does not make them compatible with Apple T8010.

This means the remaining three features cannot be enabled safely by changing
Kconfig symbols or adding guessed device-tree compatibles. Work must begin
with hardware identification, power/clock/reset sequencing, firmware
requirements, register documentation or measured traces, then a driver and
physical-device validation. Until then, retain the framebuffer/software
rendering path and leave audio, GPU acceleration, and camera unavailable.

Pinned source audit links:
- https://github.com/corellium/linux-sandcastle/tree/0c2f7dda13d67bb7e06123df516f8bdb1000a79b/arch/arm64/boot/dts/hx
- https://github.com/corellium/linux-sandcastle/tree/0c2f7dda13d67bb7e06123df516f8bdb1000a79b/drivers/gpu
- https://github.com/corellium/linux-sandcastle/tree/0c2f7dda13d67bb7e06123df516f8bdb1000a79b/sound
- https://github.com/corellium/linux-sandcastle/tree/0c2f7dda13d67bb7e06123df516f8bdb1000a79b/drivers/media

## Workstream A — GPU

### Initial approach
1. Identify the exact GPU block, revision, register map, power/clock dependencies, firmware requirements, and memory/IOMMU setup from public documentation and existing upstream code. Do not assume that the M-series Asahi AGX driver or a generic PowerVR driver matches T8010.
2. Inventory the current Sandcastle kernel for DRM, framebuffer, IOMMU, Apple power/clock, and GPU-related code.
3. Preserve the loader-provided simple framebuffer as the safe display path.
4. Make software rendering available for the desktop shell (llvmpipe or another supported Mesa software path) while hardware acceleration is unavailable.
5. Only start a hardware driver after the GPU identity and initialization sequence are verified. Implement a minimal DRM/KMS bring-up first; acceleration comes later.

### Acceptance tests
- Kernel detects the GPU without unsafe register probing.
- Display remains stable across repeated UI redraws and suspend/resume tests where supported.
- DRM device and userspace renderer identify themselves accurately.
- A known graphics test runs without kernel warnings, hangs, overheating, or corrupted display.
- Report hardware acceleration separately from software rendering.

Status: **Not implemented / research required**.

## Workstream B — Audio

### Initial approach
1. Identify the exact codec, audio DSP/AOP path, I2S/TDM controller, clocks, regulators, GPIOs, and speaker/headphone routing for N112 from device-tree and read-only hardware metadata.
2. Search the Sandcastle kernel and current Linux ASoC tree for matching controller and codec drivers. Do not copy a codec driver from a different iPhone model without confirming the part and wiring.
3. Add only verified device-tree nodes and bindings. Keep the sound card disabled until clocks, power sequencing, and routing are understood.
4. Bring up capture/playback in stages: codec detection, headphone output, speaker output, then microphone input.
5. Add a minimal ALSA configuration only after the kernel exposes a correct sound card.

### Acceptance tests
- Correct codec and sound card are identified.
- Headphone and speaker output pass repeatable left/right and volume tests without pops or unsafe levels.
- Microphone capture passes a recorded playback check.
- No kernel faults or unexpected power/thermal behavior.

Status: **Not implemented / codec and routing identification required**.

## Workstream C — Camera

### Initial approach
1. Identify the front/rear sensor part numbers, camera bridge, CSI/ISP blocks, power rails, clocks, reset lines, and calibration data requirements for N112.
2. Determine whether a usable ISP driver and firmware interface exist for T8010. A sensor driver alone is not enough if the ISP/media pipeline is unavailable.
3. Use the Linux media-controller and V4L2 frameworks; add sensor and bridge drivers only after the hardware topology and register sequences are documented.
4. Keep camera support disabled until power sequencing and sensor initialization are understood. Never experiment with unknown rails or undocumented writes on a live device.
5. First target: enumerate a sensor and capture a single low-resolution frame; later add preview and camera switching.

### Acceptance tests
- Sensor and media graph enumerate correctly.
- A captured frame has valid dimensions, format, and stable timestamps.
- Repeated capture/stop cycles do not hang the camera, kernel, or device.
- No unverified calibration, firmware, or Apple proprietary blobs are redistributed.

Status: **Not implemented / sensor and ISP research required**.

## Shared rules

- Work on a dedicated driver branch; do not patch the bootloader or modify iOS/APFS/NAND.
- Prefer upstream Linux drivers and documented interfaces. Keep any out-of-tree code isolated and licensed.
- Do not invent device-tree compatible strings, register addresses, firmware names, or codec identities.
- Every hardware change needs a source reference, code review, build test, and device test log.
- Keep a safe simple-framebuffer and software-rendering fallback.
- Never change the public support matrix from unsupported to supported until the acceptance tests pass on an actual iPod touch 7 (N112).

## Current deliverable

The first deliverable is the investigation and fallback layer, not a fake "driver enabled" patch. A working software-rendered UI can be delivered before GPU acceleration. Audio and camera remain disabled until their exact hardware paths are identified and validated.
