# Darth Linux

**A lightweight, Arch Linux-based desktop distribution with a Sith-inspired identity and security-first defaults.**

> **Project status: Darth Linux 0.5 preview.** The repository now builds a versioned `darth-linux-0.5` ISO. The current 0.5 image is experimental until the latest Actions build passes and the ISO is boot-tested in UEFI, BIOS, and a VM. It is not yet a stable release.

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
- Include a QEMU/KVM virtual machine manager, network diagnostics toolkit, and Darth Notes.

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
The live image includes the Darth-branded installer, which launches the upstream `archinstall` engine. Select encrypted disk configuration in the guided installer and verify its summary before committing; encryption is not enabled automatically. Back up important data first because selecting a disk can permanently erase it.\n\nAfter the first boot into the installed system, connect to the internet and deploy the complete Darth desktop and package set from the project checkout:\n\n```bash\ngit clone https://github.com/Screwyougucci/DarthLinux.git\ncd DarthLinux\nsudo bash scripts/install-custom-tools.sh\n```\n\nThis post-install step downloads the full Darth package list, installs the desktop tools and Update Center, applies the system branding, and enables the desktop services. It can take time and use several gigabytes of downloads.

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

The original GTK4 **Darth Control Center** brings together VM management, VPN settings/status, network diagnostics, antivirus, system monitoring, and Darth Notes. VPN support includes native NetworkManager WireGuard and OpenVPN via its NetworkManager plugin; no VPN subscription or provider is bundled. See [docs/CONTROL-CENTER-VPN.md](docs/CONTROL-CENTER-VPN.md).

## Virtual machines, network tools, and notepad

The desktop image includes QEMU/KVM with Virtual Machine Manager, network troubleshooting tools, and Darth Notes. VM use requires hardware virtualization support and sufficient memory; see [docs/VM-NETWORK-NOTES.md](docs/VM-NETWORK-NOTES.md) for setup and safe network-isolation guidance.

## Dashboards and antivirus
The XFCE profile includes lightweight system monitors, ClamAV, and ClamUI. Custom commands include `darth-center` and `darth-av-scan`; see [docs/SECURITY-TOOLKIT.md](docs/SECURITY-TOOLKIT.md). Real-time antivirus scanning is opt-in because of memory cost.

## Layout
- `build.sh` — Archiso build entry point
- `profiles/darth/` — package selection and live-system overlay
- `scripts/` — optional helpers
- `docs/TESTING.md` — validation checklist

## Testing status
A previous development ISO build succeeded, but that does not validate version 0.5. The 0.5 workflow checks Python and shell syntax, desktop entries, catalog integrity, firewall syntax, and builds the ISO. A successful CI build still does not prove the image boots, installs, updates, or supports every hardware configuration. See [docs/TESTING.md](docs/TESTING.md) and [the 0.5 preview notes](docs/DARTH-LINUX-0.5.md).

## License
Unless otherwise noted, project source and original artwork are offered under the MIT License. Third-party components retain their own licenses.

## Residential proxy setup

The Control Center includes **Darth Proxy**, a utility for saving multiple provider-supplied HTTP or SOCKS5 residential proxy profiles, switching between them, testing connectivity, and starting a fresh provider session when the provider documents a session-ID username format. It launches dedicated Firefox profiles and does not route all system traffic. Read [docs/DARTH-PROXY.md](docs/DARTH-PROXY.md) for setup, privacy notes, and limitations.

## Booted desktop experience

Darth Linux is configured to boot to a graphical LightDM login and XFCE desktop. The default top panel includes a searchable Whisker application menu, running-window list, system tray, volume control, and clock. A Plank dock starts with Firefox, file manager, terminal, and the Darth Settings, Control Center, and AI Manager launchers. NetworkManager, Bluetooth, and power applets start with the desktop session. See [docs/DESKTOP-BOOT.md](docs/DESKTOP-BOOT.md).

## Expanded System Settings

Darth Settings adds dedicated Updates, Audio, Display, Video, Network, Security, and System pages. It includes output-volume and mute controls through PipeWire, microphone/device configuration through the audio mixer, display configuration, laptop brightness shortcuts, webcam controls, MPV playback, and system/network utilities. Hardware-dependent controls require supported devices and permissions. See [docs/DARTH-SETTINGS.md](docs/DARTH-SETTINGS.md).

## Local AI Model Manager

Darth Linux includes **Darth AI Model Manager**, a GTK desktop utility for downloading GGUF models from Hugging Face and running them locally with llama.cpp. It supports CPU inference, local model storage, a loopback-only chat UI, and stop/start controls. See [docs/DARTH-AI-MANAGER.md](docs/DARTH-AI-MANAGER.md) for model selection, hardware guidance, and security notes.

## Darth Linux 0.5 preview

Version 0.5 focuses on a unified Darth desktop identity and a built-in Update Center. The login screen, boot splash, terminal, file-manager launcher, installer, Settings, and Control Center share the graphite/crimson theme and Darth icon. Settings can safely check Arch repository updates, preview packages, and request administrator approval for a complete `pacman -Syu` upgrade; it can also update per-user Flatpak apps when Flatpak is installed. Arch remains the package and system foundation. See [docs/DARTH-WATCHTOWER-0.2.md](docs/DARTH-WATCHTOWER-0.2.md) for Watchtower's visual editions, analytics panels, customization features, and acceptance tests, and [docs/DARTH-DRIVER-MANAGER-0.2.md](docs/DARTH-DRIVER-MANAGER-0.2.md) for planned hardware detection, driver/firmware status, graphics guidance, safe package installation, and hardware validation.

## Darth Linux 0.3 — Hardware Compatibility

Version 0.3 starts with the read-only `darth-hwcheck` diagnostic. It reports basic system and device inventory, boot mode, memory, virtualization flags, and possible current-boot firmware/driver errors. It does not automatically change drivers. See [the 0.3 hardware compatibility plan and validation matrix](docs/DARTH-LINUX-0.3-HARDWARE-COMPATIBILITY.md). Physical hardware testing is still required before making compatibility claims.\n

## Darth Update Center

Open **Darth Settings → Updates** to check for package updates, inspect the pending package list, and apply a complete system upgrade after administrator authentication. The checker uses `checkupdates` from `pacman-contrib` so the preview does not partially update the live pacman database; installation uses `pacman -Syu` rather than an unsafe partial upgrade. If Flatpak is installed, the page also updates apps installed in the current user's Flatpak scope. System update logs are saved to `~/.local/state/darth-linux/system-update.log`.
