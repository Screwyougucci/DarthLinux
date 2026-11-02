# Darth Security Toolkit and Dashboards

## System dashboards

- `btop`: lightweight terminal dashboard for CPU, memory, processes, disks, and network.
- `bottom`: alternative terminal system monitor.
- XFCE task manager and panel plugins provide graphical process, CPU, disk, and sensor views.
- `darth-center`: original read-only Darth status screen showing host/kernel, CPU/RAM/disk, firewall state, ClamAV service state, and signature database timestamp.

Run `darth-center` in a terminal. It refreshes every three seconds and exits with Ctrl+C.

## Antivirus and integrity

- ClamAV is the primary on-demand antivirus engine.
- ClamUI is a graphical front end for ClamAV.
- `darth-av-scan /path` updates signatures when possible and scans the selected path. It never deletes or quarantines files automatically; inspect its log at `~/darth-clamav-scan.log`.
- Rootkit Hunter (`rkhunter`) is an additional heuristic rootkit checker, not a substitute for antivirus.

ClamAV real-time/on-access scanning is deliberately not enabled by default. Its daemon and signature database can consume substantial RAM; on-access scanning can require around 1.6 GB or more for signatures alone. On low-memory systems, use scheduled signature updates and manual/on-demand scans. Initialize and configure ClamAV before enabling its services; consult the ArchWiki ClamAV guide.

## Install custom commands

```bash
sudo bash scripts/install-custom-tools.sh
```

## Existing custom utilities

- `darth-audit`: read-only local snapshot of kernel, firewall/network service status, block-device/filesystem view, listening sockets, and SSH server configuration.
- `darth-scope-scan`: Nmap host discovery only against a private IPv4 range no larger than /24, with explicit authorization confirmation.

## Responsible use

Only assess systems and wireless networks you own or have explicit written permission to test. The dashboard is informational, not an intrusion detection system. Antivirus and rootkit tools can miss threats and can produce false positives.

## Build validation

Package names are based on the Arch package database/ArchWiki at the time of editing, but the complete image has not yet been built. Validate every package in an Archiso build before publishing.
