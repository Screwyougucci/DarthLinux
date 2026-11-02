# Darth Linux

**A lightweight, Arch Linux-based desktop distribution with a Sith-inspired identity and security-first defaults.**

> **Project status: early development.** This repository contains the initial build scaffold. No release ISO has been published or validated yet. Treat generated images as experimental until the test checklist is complete.

## Goals
- Run well on older laptops and low-resource computers.
- Provide a bootable live USB and an installable system.
- Use XFCE for a responsive desktop.
- Make full-disk encryption available during installation.
- Ship sensible network-security defaults and useful defensive tools.
- Keep the base system lean, transparent, and free of project-added telemetry.
- Include a broad toolkit for authorized network, web, wireless, forensics, and reverse-engineering lab work.
- Include original Darth utilities with conservative, scope-limited defaults.
- Provide lightweight system dashboards and on-demand antivirus tools.
- Include a QEMU/KVM virtual machine manager, network diagnostics toolkit, and Mousepad notepad.

## Visual identity
Near-black graphite, crimson accents, and restrained tactical details. Artwork is original project branding, not affiliated with Lucasfilm, Disney, or Arch Linux.

## Build on Arch Linux
Requires an updated Arch Linux host or properly configured Arch VM, root privileges, internet, archiso, git, and several GB of free disk space.

```bash
git clone https://github.com/Screwyougucci/DarthLinux.git
cd DarthLinux
sudo bash build.sh
```

The ISO is written to `out/`; temporary work files are in `work/`.

## Install and encryption
The live image includes `archinstall`. Run it from the live session and select encrypted disk configuration in the guided installer. Back up important data first: selecting a disk can permanently erase it. Encryption is not enabled automatically; verify the installer summary before committing.

## Security
- nftables baseline denies unsolicited inbound traffic.
- Outbound traffic is allowed for usability; this is not an anonymity system.
- No OS can be made “unhackable.” Keep it updated and use strong unique passwords.
- Use security tools only on systems you own or have explicit permission to assess.

## Optional toolkit
Run `sudo bash scripts/install-security-tools.sh` after installation to add the optional defensive / authorized lab tools. Review the script before running it.

## Security toolkit
The live profile includes a starter set of network, web, wireless-audit, forensics, and reverse-engineering packages. See [docs/SECURITY-TOOLKIT.md](docs/SECURITY-TOOLKIT.md) for the custom utilities and responsible-use boundaries. The package list is experimental until an Archiso build validates every package name.

## Darth Control Center and VPN

The original GTK4 **Darth Control Center** brings together VM management, VPN settings/status, network diagnostics, antivirus, system monitoring, and Mousepad. VPN support includes native NetworkManager WireGuard and OpenVPN via its NetworkManager plugin; no VPN subscription or provider is bundled. See [docs/CONTROL-CENTER-VPN.md](docs/CONTROL-CENTER-VPN.md).

## Virtual machines, network tools, and notepad

The desktop image includes QEMU/KVM with Virtual Machine Manager, network troubleshooting tools, and Mousepad. VM use requires hardware virtualization support and sufficient memory; see [docs/VM-NETWORK-NOTES.md](docs/VM-NETWORK-NOTES.md) for setup and safe network-isolation guidance.

## Dashboards and antivirus
The XFCE profile includes lightweight system monitors, ClamAV, and ClamUI. Custom commands include `darth-center` and `darth-av-scan`; see [docs/SECURITY-TOOLKIT.md](docs/SECURITY-TOOLKIT.md). Real-time antivirus scanning is opt-in because of memory cost.

## Layout
- `build.sh` — Archiso build entry point
- `profiles/darth/` — package selection and live-system overlay
- `scripts/` — optional helpers
- `docs/TESTING.md` — validation checklist

## Testing status
No boot test, hardware compatibility test, installer test, or encryption verification has been completed yet. See [docs/TESTING.md](docs/TESTING.md).

## License
Unless otherwise noted, project source and original artwork are offered under the MIT License. Third-party components retain their own licenses.

## Residential proxy setup

The Control Center includes **Darth Proxy**, a utility for saving multiple provider-supplied HTTP or SOCKS5 residential proxy profiles, switching between them, testing connectivity, and starting a fresh provider session when the provider documents a session-ID username format. It launches dedicated Firefox profiles and does not route all system traffic. Read [docs/DARTH-PROXY.md](docs/DARTH-PROXY.md) for setup, privacy notes, and limitations.

## Local AI Model Manager

Darth Linux includes **Darth AI Model Manager**, a GTK desktop utility for downloading GGUF models from Hugging Face and running them locally with llama.cpp. It supports CPU inference, local model storage, a loopback-only chat UI, and stop/start controls. See [docs/DARTH-AI-MANAGER.md](docs/DARTH-AI-MANAGER.md) for model selection, hardware guidance, and security notes.
