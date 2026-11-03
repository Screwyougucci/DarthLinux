#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PROFILE_DIR="$ROOT_DIR/profiles/darth"
WORK_DIR="$ROOT_DIR/work"
OUT_DIR="$ROOT_DIR/out"
BASE_PROFILE="/usr/share/archiso/configs/releng"

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
[[ $EUID -eq 0 ]] || die "Run with sudo: sudo bash ./build.sh"
command -v mkarchiso >/dev/null 2>&1 || die "Install archiso: sudo pacman -S archiso"
[[ -d "$BASE_PROFILE" ]] || die "Official Archiso releng profile not found at $BASE_PROFILE"
[[ -f "$PROFILE_DIR/packages.x86_64" ]] || die "Missing project package list"

mkdir -p "$WORK_DIR" "$OUT_DIR"
TMP_PROFILE="$(mktemp -d /tmp/darth-linux-profile.XXXXXX)"
trap 'rm -rf "$TMP_PROFILE"' EXIT
cp -a "$BASE_PROFILE/." "$TMP_PROFILE/"
cat "$PROFILE_DIR/packages.x86_64" >> "$TMP_PROFILE/packages.x86_64"
cp -a "$PROFILE_DIR/airootfs/." "$TMP_PROFILE/airootfs/"

# Bake the project's original command-line and GTK tools into the live image.
BIN_DIR="$TMP_PROFILE/airootfs/usr/local/bin"
APP_DIR="$TMP_PROFILE/airootfs/usr/share/applications"
mkdir -p "$BIN_DIR" "$APP_DIR"
for tool in darth-audit darth-scope-scan darth-center darth-av-scan darth-control-center darth-proxy darth-ai-manager darth-settings darth-watchtower darth-driver-manager darth-hwcheck darth-store darth-guardian darth-sentinel darth-recovery darth-privacy darth-lockdown darth-redlab darth-notes; do
  [[ -f "$ROOT_DIR/tools/$tool" ]] || die "Missing custom tool: $tool"
  install -Dm755 "$ROOT_DIR/tools/$tool" "$BIN_DIR/$tool"
done
for desktop in darth-control-center.desktop darth-ai-manager.desktop darth-settings.desktop darth-watchtower.desktop darth-driver-manager.desktop darth-store.desktop darth-notes.desktop; do
  [[ -f "$ROOT_DIR/packaging/$desktop" ]] || die "Missing desktop entry: $desktop"
  install -Dm644 "$ROOT_DIR/packaging/$desktop" "$APP_DIR/$desktop"
done
# Convert text placeholders into real systemd unit symlinks in the build tree.
for unit in NetworkManager.service nftables.service \
            virtqemud.socket virtnetworkd.socket virtstoraged.socket \
            virtsecretd.socket virtlogd.socket virtlockd.socket \
            virtnodedevd.socket virtnwfilterd.socket virtinterfaced.socket; do
  link="$TMP_PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/$unit"
  rm -f "$link"
  ln -s "../../../../usr/lib/systemd/system/$unit" "$link"
  expected="$TMP_PROFILE/airootfs/usr/lib/systemd/system/$unit"
  actual="$(realpath -m "$link")"
  [[ "$actual" == "$expected" ]] || die "Incorrect systemd link target for $unit: $actual"
done
# Autostart libvirt's packaged NAT network for ordinary QEMU guest connectivity.
LIBVIRT_NETWORKS="$TMP_PROFILE/airootfs/etc/libvirt/qemu/networks"
mkdir -p "$LIBVIRT_NETWORKS/autostart"
ln -sfn ../default.xml "$LIBVIRT_NETWORKS/autostart/default.xml"
network_link="$LIBVIRT_NETWORKS/autostart/default.xml"
expected_network="$LIBVIRT_NETWORKS/default.xml"
actual_network="$(realpath -m "$network_link")"
[[ "$actual_network" == "$expected_network" ]] || die "Incorrect libvirt default network autostart link: $actual_network"
# Start a PolicyKit authentication agent in XFCE sessions so pkexec
# can display the administrator password prompt for Darth Store.
POLKIT_AUTOSTART="$TMP_PROFILE/airootfs/etc/xdg/autostart"
mkdir -p "$POLKIT_AUTOSTART"
cat > "$POLKIT_AUTOSTART/polkit-gnome-authentication-agent-1.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=PolicyKit Authentication Agent
Comment=Authentication agent for privileged desktop actions
Exec=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
OnlyShowIn=XFCE;
NoDisplay=true
StartupNotify=false
EOF
# Boot to the graphical desktop and show the LightDM login screen.
mkdir -p "$TMP_PROFILE/airootfs/etc/systemd/system/graphical.target.wants"
ln -sf /usr/lib/systemd/system/graphical.target "$TMP_PROFILE/airootfs/etc/systemd/system/default.target"
ln -sf /usr/lib/systemd/system/lightdm.service "$TMP_PROFILE/airootfs/etc/systemd/system/display-manager.service"
ln -sf /usr/lib/systemd/system/lightdm.service "$TMP_PROFILE/airootfs/etc/systemd/system/graphical.target.wants/lightdm.service"
# Copy the project desktop defaults into the live user's skeleton.
mkdir -p "$TMP_PROFILE/airootfs/etc/skel/Desktop"
find "$TMP_PROFILE/airootfs/etc/skel" -type f -name '*.desktop' -exec chmod 755 {} +
sed -i 's/^iso_label=.*/iso_label="DARTH_LINUX"/' "$TMP_PROFILE/profiledef.sh"
sed -i 's/^iso_name=.*/iso_name="darth-linux"/' "$TMP_PROFILE/profiledef.sh"
sed -i 's/^iso_publisher=.*/iso_publisher="Darth Linux Project"/' "$TMP_PROFILE/profiledef.sh"

printf '\nBuilding Darth Linux from the official Archiso releng profile...\n'
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$TMP_PROFILE"
printf '\nBuild finished. Check the ISO in: %s\n' "$OUT_DIR"
