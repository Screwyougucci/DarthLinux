# Darth Linux image validation checklist

Do not call an image a release until the checks below are completed and recorded.

## Build
- [ ] Build from a clean, updated Arch Linux host.
- [ ] Confirm every package resolves from enabled repositories.
- [ ] Record build date, Archiso version, package snapshot, and ISO SHA-256.
- [ ] Confirm boot in UEFI and BIOS/legacy modes where supported.

## Live session
- [ ] Boot in a VM with 2 GB RAM and record performance.
- [ ] Boot on at least one low-end physical laptop.
- [ ] Check XFCE, display, keyboard, touchpad, audio, and networking.
- [ ] Confirm NetworkManager starts.
- [ ] Confirm nftables loads and does not break required live-session behavior.

## Installation and encryption
- [ ] Run archinstall in a disposable VM.
- [ ] Verify encrypted root and swap configuration in the installer summary.
- [ ] Complete installation and reboot.
- [ ] Verify the encryption passphrase is requested before mounting encrypted root.
- [ ] Document recovery and backup procedures.

## Security and usability
- [ ] Verify no project-added telemetry services are enabled.
- [ ] Review listening sockets and firewall behavior.
- [ ] Verify package updates work.
- [ ] Test the optional toolkit installer.
- [ ] Check contrast, readability, and sensible defaults.

## Release gate
A release requires successful build logs, SHA-256 checksum, VM boot results, installation results, encryption verification, and known issues. Until then, mark images experimental.
