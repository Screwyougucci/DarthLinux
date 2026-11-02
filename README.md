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
- Provide optional tools for authorized security testing and lab work.

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

## Layout
- `build.sh` — Archiso build entry point
- `profiles/darth/` — package selection and live-system overlay
- `scripts/` — optional helpers
- `docs/TESTING.md` — validation checklist

## Testing status
No boot test, hardware compatibility test, installer test, or encryption verification has been completed yet. See [docs/TESTING.md](docs/TESTING.md).

## License
Unless otherwise noted, project source and original artwork are offered under the MIT License. Third-party components retain their own licenses.
