#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo bash scripts/install-custom-tools.sh" >&2; exit 1; }
ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
install -Dm755 "$ROOT/tools/darth-audit" /usr/local/bin/darth-audit
install -Dm755 "$ROOT/tools/darth-scope-scan" /usr/local/bin/darth-scope-scan
echo "Installed: darth-audit, darth-scope-scan"
