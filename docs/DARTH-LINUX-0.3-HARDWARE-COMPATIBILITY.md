# Darth Linux 0.3 — Hardware Compatibility

## First implementation

Darth Linux 0.3 begins with `darth-hwcheck`, a read-only diagnostic included in the live image at `/usr/local/bin/darth-hwcheck`.

Run:

```bash
darth-hwcheck
darth-hwcheck --json > darth-hardware-report.json
```

The checker records CPU architecture, kernel, memory, boot mode, CPU virtualization flags, PCI and USB inventory (when `pciutils` and `usbutils` are present), and possible firmware/driver errors from the current boot's kernel journal. It uses Python's standard library and does not install, remove, blacklist, or reconfigure drivers.

## Compatibility status meanings

- `no-obvious-blockers`: the limited checks found no immediate warning; this is not a compatibility certification.
- `needs-review`: one or more checks found a condition that deserves investigation.
- `incomplete-data`: the environment did not expose enough information to make a useful assessment.

The memory indicator uses 4 GiB as a practical target, not a hard requirement. A machine below that may still boot, but desktop performance can be limited. Legacy/unknown boot mode is a review item, not proof that BIOS boot is unsupported.

## Hardware validation matrix

The project must gather real results across representative systems before claiming broad compatibility:

| Area | Required validation |
|---|---|
| CPU | x86_64 boot; older Intel and AMD generations |
| Memory | 2, 4, 8, and 16 GiB test profiles where available |
| Firmware | UEFI and legacy BIOS where hardware supports it |
| Graphics | Intel integrated, AMD integrated/discrete, NVIDIA; live desktop and resolution changes |
| Networking | Ethernet, Intel/Realtek Wi-Fi, USB Wi-Fi, Bluetooth |
| Input | USB keyboard/mouse, laptop touchpad, function keys |
| Audio | speakers, headphones, microphone, suspend/resume |
| Storage | SATA SSD/HDD, NVMe, USB live media; installer visibility |
| Power | battery reporting, brightness, suspend/resume |
| Install | archinstall completion, bootloader, encrypted root and recovery path |

For each physical test, record vendor/model, CPU, RAM, GPU, Wi-Fi chipset, firmware mode, ISO SHA-256, boot result, working devices, failures, and relevant logs. Never infer support for a device family from one machine.

## Current limits

The checker is a first diagnostic layer, not an automatic driver installer and not a compatibility database. It cannot prove that Wi-Fi firmware, graphics acceleration, suspend, sound, printers, cameras, encryption, or installation work. VM results do not replace physical-machine tests.

## CI validation

The ISO workflow compiles the checker and runs `python tools/darth-hwcheck --self-test` before building the image. This validates basic report structure and packaging; it does not emulate real hardware.
