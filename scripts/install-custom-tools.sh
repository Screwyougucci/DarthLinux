#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo bash scripts/install-custom-tools.sh" >&2; exit 1; }
ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
install -Dm755 "$ROOT/tools/darth-audit" /usr/local/bin/darth-audit
install -Dm755 "$ROOT/tools/darth-scope-scan" /usr/local/bin/darth-scope-scan
install -Dm755 "$ROOT/tools/darth-center" /usr/local/bin/darth-center
install -Dm755 "$ROOT/tools/darth-av-scan" /usr/local/bin/darth-av-scan
install -Dm755 "$ROOT/tools/darth-control-center" /usr/local/bin/darth-control-center
install -Dm644 "$ROOT/packaging/darth-control-center.desktop" /usr/share/applications/darth-control-center.desktop
echo "Installed: darth-audit, darth-scope-scan, darth-center, darth-av-scan, darth-control-center"
echo "Launch Darth Control Center from the XFCE applications menu."
