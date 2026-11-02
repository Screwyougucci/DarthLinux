#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PROFILE_DIR="$ROOT_DIR/profiles/darth"
WORK_DIR="$ROOT_DIR/work"
OUT_DIR="$ROOT_DIR/out"
BASE_PROFILE="/usr/share/archiso/configs/releng"

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
[[ $EUID -eq 0 ]] || die "Run with sudo: sudo ./build.sh"
command -v mkarchiso >/dev/null 2>&1 || die "Install archiso: sudo pacman -S archiso"
[[ -d "$BASE_PROFILE" ]] || die "Official Archiso releng profile not found at $BASE_PROFILE"
[[ -f "$PROFILE_DIR/packages.x86_64" ]] || die "Missing project package list"

mkdir -p "$WORK_DIR" "$OUT_DIR"
TMP_PROFILE="$(mktemp -d /tmp/darth-linux-profile.XXXXXX)"
trap 'rm -rf "$TMP_PROFILE"' EXIT
cp -a "$BASE_PROFILE/." "$TMP_PROFILE/"
cat "$PROFILE_DIR/packages.x86_64" >> "$TMP_PROFILE/packages.x86_64"
cp -a "$PROFILE_DIR/airootfs/." "$TMP_PROFILE/airootfs/"
sed -i 's/^iso_label=.*/iso_label="DARTH_LINUX"/' "$TMP_PROFILE/profiledef.sh"
sed -i 's/^iso_name=.*/iso_name="darth-linux"/' "$TMP_PROFILE/profiledef.sh"
sed -i 's/^iso_publisher=.*/iso_publisher="Darth Linux Project"/' "$TMP_PROFILE/profiledef.sh"

printf '\nBuilding Darth Linux from the official Archiso releng profile...\n'
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$TMP_PROFILE"
printf '\nBuild finished. Check the ISO in: %s\n' "$OUT_DIR"
