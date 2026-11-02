#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo bash scripts/install-custom-tools.sh" >&2; exit 1; }
ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
install -Dm755 "$ROOT/tools/darth-audit" /usr/local/bin/darth-audit
install -Dm755 "$ROOT/tools/darth-scope-scan" /usr/local/bin/darth-scope-scan
install -Dm755 "$ROOT/tools/darth-center" /usr/local/bin/darth-center
install -Dm755 "$ROOT/tools/darth-av-scan" /usr/local/bin/darth-av-scan
install -Dm755 "$ROOT/tools/darth-control-center" /usr/local/bin/darth-control-center
install -Dm755 "$ROOT/tools/darth-proxy" /usr/local/bin/darth-proxy
install -Dm755 "$ROOT/tools/darth-ai-manager" /usr/local/bin/darth-ai-manager
install -Dm644 "$ROOT/packaging/darth-control-center.desktop" /usr/share/applications/darth-control-center.desktop
install -Dm644 "$ROOT/packaging/darth-ai-manager.desktop" /usr/share/applications/darth-ai-manager.desktop
echo "Installed: darth-audit, darth-scope-scan, darth-center, darth-av-scan, darth-control-center, darth-proxy, darth-ai-manager"
echo "Launch Darth Control Center from the XFCE applications menu."
