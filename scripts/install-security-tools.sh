#!/usr/bin/env bash
set -Eeuo pipefail
if [[ $EUID -ne 0 ]]; then echo "Run with sudo: sudo $0" >&2; exit 1; fi
command -v pacman >/dev/null 2>&1 || { echo "This helper is intended for Arch Linux." >&2; exit 1; }
echo "Installing optional defensive and authorized security-lab tools..."
pacman -S --needed nmap tcpdump traceroute wireshark-cli testdisk clamav lynis
echo "Use these tools only on systems you own or are explicitly authorized to test."
