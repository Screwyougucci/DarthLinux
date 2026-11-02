#!/usr/bin/env bash
set -Eeuo pipefail

[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo bash scripts/install-custom-tools.sh" >&2; exit 1; }
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

tools=(
  darth-audit darth-scope-scan darth-center darth-av-scan
  darth-control-center darth-proxy darth-ai-manager darth-settings
  darth-watchtower darth-driver-manager darth-hwcheck darth-store
  darth-guardian darth-sentinel darth-recovery darth-privacy
  darth-lockdown darth-redlab
)

for tool in "${tools[@]}"; do
  source_file="$ROOT/tools/$tool"
  [[ -f "$source_file" ]] || { echo "Missing tool: $source_file" >&2; exit 1; }
  install -Dm755 "$source_file" "/usr/local/bin/$tool"
done

desktop_entries=(
  darth-control-center.desktop darth-ai-manager.desktop
  darth-settings.desktop darth-watchtower.desktop
  darth-driver-manager.desktop darth-store.desktop
)

for desktop in "${desktop_entries[@]}"; do
  source_file="$ROOT/packaging/$desktop"
  [[ -f "$source_file" ]] || { echo "Missing desktop entry: $source_file" >&2; exit 1; }
  install -Dm644 "$source_file" "/usr/share/applications/$desktop"
done

echo "Installed ${#tools[@]} Darth Linux tools and ${#desktop_entries[@]} desktop entries."
echo "Launch Darth Control Center or Darth Settings from the XFCE applications menu."
