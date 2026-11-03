#!/usr/bin/env bash
set -Eeuo pipefail

[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo bash scripts/install-custom-tools.sh" >&2; exit 1; }
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
[[ "$VERSION" == "0.5" ]] || { echo "This installer expects Darth Linux 0.5 sources." >&2; exit 1; }
command -v pacman >/dev/null 2>&1 || { echo "This helper is intended for an Arch Linux installation." >&2; exit 1; }

mapfile -t packages < <(grep -Ev '^[[:space:]]*(#|$)' "$ROOT/profiles/darth/packages.x86_64")
echo "Installing the Darth Linux $VERSION package set. This may download several gigabytes."
pacman -Syu --needed --noconfirm -- "${packages[@]}"

tools=(
  darth-audit darth-scope-scan darth-center darth-av-scan
  darth-control-center darth-proxy darth-ai-manager darth-settings
  darth-watchtower darth-driver-manager darth-hwcheck darth-store
  darth-guardian darth-sentinel darth-recovery darth-privacy
  darth-lockdown darth-redlab darth-notes darth-installer
  darth-terminal darth-files darth-installer-session
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
  darth-notes.desktop darth-installer.desktop
  darth-terminal.desktop darth-files.desktop
)
for desktop in "${desktop_entries[@]}"; do
  source_file="$ROOT/packaging/$desktop"
  [[ -f "$source_file" ]] || { echo "Missing desktop entry: $source_file" >&2; exit 1; }
  install -Dm644 "$source_file" "/usr/share/applications/$desktop"
done

ICON_SOURCE="$ROOT/profiles/darth/airootfs/usr/share/icons/hicolor/scalable/apps"
install -d /usr/share/icons/hicolor/scalable/apps
for icon in "$ICON_SOURCE"/*.svg; do
  [[ -f "$icon" ]] || continue
  install -Dm644 "$icon" "/usr/share/icons/hicolor/scalable/apps/${icon##*/}"
done
install -Dm644 "$ROOT/profiles/darth/airootfs/usr/share/backgrounds/darth-linux/wallpaper.svg" \
  /usr/share/backgrounds/darth-linux/wallpaper.svg
install -Dm644 "$ROOT/profiles/darth/airootfs/etc/lightdm/lightdm-gtk-greeter.conf" \
  /etc/lightdm/lightdm-gtk-greeter.conf
install -Dm644 "$ROOT/profiles/darth/airootfs/etc/darth-linux-release" /etc/darth-linux-release
printf 'Darth Linux %s // Installed System\n' "$VERSION" > /etc/issue

# Preserve existing user preferences while supplying Darth defaults for any
# settings files that have not yet been created.
install -d /etc/skel/.config
cp -an "$ROOT/profiles/darth/airootfs/etc/skel/.config/." /etc/skel/.config/
install -m644 "$ROOT/profiles/darth/airootfs/etc/skel/.bashrc" /etc/skel/.bashrc
if [[ -n "${SUDO_USER:-}" ]] && getent passwd "$SUDO_USER" >/dev/null; then
  user_home="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
  user_group="$(id -gn "$SUDO_USER")"
  install -d -o "$SUDO_USER" -g "$user_group" "$user_home/.config"
  cp -an /etc/skel/.config/. "$user_home/.config/"
  if [[ ! -e "$user_home/.bashrc" ]]; then
    install -o "$SUDO_USER" -g "$user_group" -m644 /etc/skel/.bashrc "$user_home/.bashrc"
  fi
  chown -R "$SUDO_USER:$user_group" "$user_home/.config"
fi

POLKIT_AUTOSTART=/etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop
install -d /etc/xdg/autostart
cat > "$POLKIT_AUTOSTART" <<'EOF'
[Desktop Entry]
Type=Application
Name=PolicyKit Authentication Agent
Comment=Authentication agent for privileged desktop actions
Exec=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
OnlyShowIn=XFCE;
NoDisplay=true
StartupNotify=false
EOF

gtk-update-icon-cache -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
systemctl set-default graphical.target
systemctl enable NetworkManager.service nftables.service lightdm.service
for unit in virtqemud.socket virtnetworkd.socket virtstoraged.socket virtsecretd.socket \
            virtlogd.socket virtlockd.socket virtnodedevd.socket virtnwfilterd.socket \
            virtinterfaced.socket; do
  systemctl enable "$unit" 2>/dev/null || true
done
network_dir=/etc/libvirt/qemu/networks
if [[ -f "$network_dir/default.xml" ]]; then
  install -d "$network_dir/autostart"
  ln -sfn ../default.xml "$network_dir/autostart/default.xml"
fi

echo "Darth Linux $VERSION desktop components installed."
echo "Restart the computer to start the branded LightDM/XFCE desktop."
echo "The system updater is in Darth Settings > Updates."
echo "Arch remains the underlying system and package-management base."
