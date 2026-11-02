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
for tool in darth-audit darth-scope-scan darth-center darth-av-scan \
            darth-control-center darth-proxy darth-ai-manager darth-settings; do
  [[ -f "$ROOT_DIR/tools/$tool" ]] || die "Missing custom tool: $tool"
  install -Dm755 "$ROOT_DIR/tools/$tool" "$BIN_DIR/$tool"
done
for desktop in darth-control-center.desktop darth-ai-manager.desktop darth-settings.desktop; do
  [[ -f "$ROOT_DIR/packaging/$desktop" ]] || die "Missing desktop entry: $desktop"
  install -Dm644 "$ROOT_DIR/packaging/$desktop" "$APP_DIR/$desktop"
done
# Convert text placeholders into real systemd unit symlinks in the build tree.
for unit in NetworkManager nftables; do
  link="$TMP_PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/$unit.service"
  rm -f "$link"
  ln -s "../../../../usr/lib/systemd/system/$unit.service" "$link"
done
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
