#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${DARTH_BUILD_WORKDIR:-$ROOT_DIR/out/sandcastle}"
BUILDROOT_DIR="$WORK_DIR/sandcastle-buildroot"
ARTIFACT_DIR="${DARTH_ARTIFACT_DIR:-$ROOT_DIR/out/artifacts}"
JOBS="${JOBS:-2}"

BUILDROOT_SHA="95af39e1b271f2b25f73b32555db92c83f916ca8"
KERNEL_SHA="0c2f7dda13d67bb7e06123df516f8bdb1000a79b"
PROJECTSANDCASTLE_SHA="03db9c6ae04141eb940f3b9f56d446f50d57fadf"
KERNEL_CONFIG_BLOB_SHA="643a97e52a5a0f09457844b7487d77ed846eede9"

mkdir -p "$WORK_DIR" "$ARTIFACT_DIR"

if [ ! -d "$BUILDROOT_DIR/.git" ]; then
    mkdir -p "$BUILDROOT_DIR"
    git -C "$BUILDROOT_DIR" init
    git -C "$BUILDROOT_DIR" remote add origin https://github.com/corellium/sandcastle-buildroot.git
    git -C "$BUILDROOT_DIR" fetch --depth=1 origin "$BUILDROOT_SHA"
    git -C "$BUILDROOT_DIR" checkout --detach FETCH_HEAD
else
    git -C "$BUILDROOT_DIR" fetch --depth=1 origin "$BUILDROOT_SHA"
    git -C "$BUILDROOT_DIR" checkout --detach "$BUILDROOT_SHA"
fi

mkdir -p "$BUILDROOT_DIR/output"

ACTUAL_BUILDROOT_SHA="$(git -C "$BUILDROOT_DIR" rev-parse HEAD)"
if [ "$ACTUAL_BUILDROOT_SHA" != "$BUILDROOT_SHA" ]; then
    echo "ERROR: unexpected Buildroot revision $ACTUAL_BUILDROOT_SHA" >&2
    exit 1
fi

# The upstream .config points inside the old output/build/linux-sandcastle-5.4
# directory. Buildroot extracts the pinned commit into linux-<commit>, so that
# path is stale. Keep the exact upstream defconfig in a stable Buildroot path.
mkdir -p "$BUILDROOT_DIR/board/darth-mobile"
wget -qO "$BUILDROOT_DIR/board/darth-mobile/hx_h9p_defconfig" \
    "https://raw.githubusercontent.com/corellium/linux-sandcastle/$KERNEL_SHA/arch/arm64/configs/hx_h9p_defconfig"
ACTUAL_KERNEL_CONFIG_BLOB_SHA="$(git -C "$BUILDROOT_DIR" hash-object board/darth-mobile/hx_h9p_defconfig)"
if [ "$ACTUAL_KERNEL_CONFIG_BLOB_SHA" != "$KERNEL_CONFIG_BLOB_SHA" ]; then
    echo "ERROR: N112 kernel defconfig does not match the pinned upstream blob." >&2
    echo "Expected $KERNEL_CONFIG_BLOB_SHA, got $ACTUAL_KERNEL_CONFIG_BLOB_SHA" >&2
    exit 1
fi

# Add the local framebuffer shell as a normal Buildroot package.
mkdir -p "$BUILDROOT_DIR/package/darth-mobile-shell"
cp "$ROOT_DIR/buildroot/package/darth-mobile-shell/Config.in" "$BUILDROOT_DIR/package/darth-mobile-shell/Config.in"
cp "$ROOT_DIR/buildroot/package/darth-mobile-shell/darth-mobile-shell.mk" "$BUILDROOT_DIR/package/darth-mobile-shell/darth-mobile-shell.mk"
mkdir -p "$BUILDROOT_DIR/package/m4"
cp "$ROOT_DIR/buildroot/patches/m4/0003-c-stack-stop-using-SIGSTKSZ.patch" "$BUILDROOT_DIR/package/m4/0003-c-stack-stop-using-SIGSTKSZ.patch"
mkdir -p "$BUILDROOT_DIR/package/fakeroot"
cp "$ROOT_DIR"/buildroot/patches/fakeroot/*.patch "$BUILDROOT_DIR/package/fakeroot/"
mkdir -p "$BUILDROOT_DIR/board/darth-mobile"
cp "$ROOT_DIR/buildroot/post-build.sh" "$BUILDROOT_DIR/board/darth-mobile/post-build.sh"
chmod 0755 "$BUILDROOT_DIR/board/darth-mobile/post-build.sh"

if ! grep -q 'package/darth-mobile-shell/Config.in' "$BUILDROOT_DIR/package/Config.in"; then
    grep -q 'source "package/hxutils/Config.in"' "$BUILDROOT_DIR/package/Config.in"
    sed -i '/source "package\/hxutils\/Config.in"/a source "package/darth-mobile-shell/Config.in"' "$BUILDROOT_DIR/package/Config.in"
fi

# Pin the HX utility source too; the historical package otherwise follows master.
python3 - "$BUILDROOT_DIR/package/hxutils/hxutils.mk" "$PROJECTSANDCASTLE_SHA" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
sha = sys.argv[2]
text = path.read_text()
old = "$(call github,corellium,projectsandcastle,master)"
new = f"$(call github,corellium,projectsandcastle,{sha})"
if old not in text and new not in text:
    raise SystemExit("Could not find the expected hxutils source declaration")
path.write_text(text.replace(old, new))
PY

# Start from Corellium's iPod 7 configuration, then harden it and add the UI.
cp "$BUILDROOT_DIR/.config" "$BUILDROOT_DIR/.config.sandcastle-upstream"
python3 - "$BUILDROOT_DIR/.config" "$KERNEL_SHA" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
kernel_sha = sys.argv[2]
text = path.read_text()
replacements = {
    'BR2_TARGET_GENERIC_ROOT_PASSWD="alpine"':
        'BR2_TARGET_GENERIC_ROOT_PASSWD="locked-by-darth-post-build"',
    'BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION="sandcastle-5.4"':
        f'BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION="{kernel_sha}"',
    'BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE="output/build/linux-sandcastle-5.4/arch/arm64/configs/hx_h9p_defconfig"':
        'BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE="board/darth-mobile/hx_h9p_defconfig"',
    '# BR2_LINUX_KERNEL_DTS_SUPPORT is not set':
        'BR2_LINUX_KERNEL_DTS_SUPPORT=y',
    'BR2_ROOTFS_POST_BUILD_SCRIPT=""':
        'BR2_ROOTFS_POST_BUILD_SCRIPT="board/darth-mobile/post-build.sh"',
    'BR2_PACKAGE_XORG7=y': '# BR2_PACKAGE_XORG7 is not set',
    'BR2_PACKAGE_FEH=y': '# BR2_PACKAGE_FEH is not set',
    'BR2_PACKAGE_FLUXBOX=y': '# BR2_PACKAGE_FLUXBOX is not set',
    'BR2_PACKAGE_DROPBEAR=y': '# BR2_PACKAGE_DROPBEAR is not set',
}
for old, new in replacements.items():
    if old not in text:
        raise SystemExit(f"Expected upstream config entry not found: {old}")
    text = text.replace(old, new, 1)

# The historical Sandcastle .config does not contain DTS name settings because
# DTS generation was disabled. Replace both optional symbols explicitly.
lines = []
for line in text.splitlines():
    if line == "# BR2_LINUX_KERNEL_DTS_SUPPORT is not set":
        continue
    if line.startswith("BR2_LINUX_KERNEL_DTS_SUPPORT="):
        continue
    if line.startswith("BR2_LINUX_KERNEL_INTREE_DTS_NAME="):
        continue
    if line == "# BR2_LINUX_KERNEL_INTREE_DTS_NAME is not set":
        continue
    lines.append(line)
text = "\n".join(lines).rstrip() + '\n'
text += 'BR2_LINUX_KERNEL_DTS_SUPPORT=y\n'
text += 'BR2_LINUX_KERNEL_INTREE_DTS_NAME="hx/hx-h9p-n112"\n'
text += 'BR2_PACKAGE_DARTH_MOBILE_SHELL=y\n'
path.write_text(text)
PY

# Do not launch the upstream desktop X server or SSH daemon.
rm -f "$BUILDROOT_DIR/sandcastle-overlay/etc/init.d/S40xorg"
rm -f "$BUILDROOT_DIR/sandcastle-overlay/etc/init.d/S50dropbear"

# Preserve the upstream N112 firmware list, HX touchscreen service, and APFS RO mount.
test -f "$BUILDROOT_DIR/sandcastle-overlay/etc/hw/hx-touch.fwlist"
grep -q 'N112.mtprops' "$BUILDROOT_DIR/sandcastle-overlay/etc/hw/hx-touch.fwlist"
grep -Eq '/hostfs[[:space:]]+apfs[[:space:]]+ro' "$BUILDROOT_DIR/sandcastle-overlay/etc/fstab"

# Buildroot expects its generated external-tree make fragment to exist even
# when no external tree is selected. Generate the empty fragment explicitly.
"$BUILDROOT_DIR/support/scripts/br2-external" -d "$BUILDROOT_DIR/output"
test -f "$BUILDROOT_DIR/output/.br2-external.mk"

make -C "$BUILDROOT_DIR" olddefconfig
grep -q '^BR2_PACKAGE_DARTH_MOBILE_SHELL=y$' "$BUILDROOT_DIR/.config"
if grep -q '^BR2_PACKAGE_DROPBEAR=y$' "$BUILDROOT_DIR/.config"; then
    echo "ERROR: Dropbear is still enabled." >&2
    exit 1
fi
if grep -q '^BR2_PACKAGE_XORG7=y$' "$BUILDROOT_DIR/.config"; then
    echo "ERROR: Xorg is still enabled." >&2
    exit 1
fi
grep -q '^BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE="board/darth-mobile/hx_h9p_defconfig"grep -q '^BR2_LINUX_KERNEL_INTREE_DTS_NAME="hx/hx-h9p-n112"$' "$BUILDROOT_DIR/.config"

# Re-extract host-m4 so the compatibility patch is applied even on incremental runs.
make -C "$BUILDROOT_DIR" host-m4-dirclean host-fakeroot-dirclean
make -C "$BUILDROOT_DIR" -j"$JOBS" DART_MOBILE_SOURCE_DIR="$ROOT_DIR"

mkdir -p "$ARTIFACT_DIR"
if [ -f "$BUILDROOT_DIR/output/images/Image.gz" ]; then
    cp "$BUILDROOT_DIR/output/images/Image.gz" "$ARTIFACT_DIR/Image.gz"
elif [ -f "$BUILDROOT_DIR/output/images/Image" ]; then
    cp "$BUILDROOT_DIR/output/images/Image" "$ARTIFACT_DIR/Image"
else
    echo "ERROR: Buildroot did not produce an ARM64 Image." >&2
    exit 1
fi

for name in hx-h9p-n112.dtb rootfs.cpio.gz; do
    if [ ! -f "$BUILDROOT_DIR/output/images/$name" ]; then
        echo "ERROR: Buildroot did not produce $name." >&2
        find "$BUILDROOT_DIR/output/images" -maxdepth 1 -type f -printf '%f\n' >&2
        exit 1
    fi
    cp "$BUILDROOT_DIR/output/images/$name" "$ARTIFACT_DIR/$name"
done

cp "$BUILDROOT_DIR/.config" "$ARTIFACT_DIR/buildroot.config"
printf 'Buildroot %s\nKernel %s\nProject Sandcastle %s\n' \
    "$BUILDROOT_SHA" "$KERNEL_SHA" "$PROJECTSANDCASTLE_SHA" > "$ARTIFACT_DIR/UPSTREAM_REVISIONS.txt"
printf "N112 kernel defconfig blob %s\n" "$KERNEL_CONFIG_BLOB_SHA" >> "$ARTIFACT_DIR/UPSTREAM_REVISIONS.txt"
(
    cd "$ARTIFACT_DIR"
    sha256sum Image* hx-h9p-n112.dtb rootfs.cpio.gz buildroot.config UPSTREAM_REVISIONS.txt > SHA256SUMS
)

echo "N112 build artifacts created in: $ARTIFACT_DIR"
 "$BUILDROOT_DIR/.config"
grep -q '^BR2_LINUX_KERNEL_DTS_SUPPORT=ygrep -q '^BR2_LINUX_KERNEL_INTREE_DTS_NAME="hx/hx-h9p-n112"$' "$BUILDROOT_DIR/.config"

# Re-extract host-m4 so the compatibility patch is applied even on incremental runs.
make -C "$BUILDROOT_DIR" host-m4-dirclean host-fakeroot-dirclean
make -C "$BUILDROOT_DIR" -j"$JOBS" DART_MOBILE_SOURCE_DIR="$ROOT_DIR"

mkdir -p "$ARTIFACT_DIR"
if [ -f "$BUILDROOT_DIR/output/images/Image.gz" ]; then
    cp "$BUILDROOT_DIR/output/images/Image.gz" "$ARTIFACT_DIR/Image.gz"
elif [ -f "$BUILDROOT_DIR/output/images/Image" ]; then
    cp "$BUILDROOT_DIR/output/images/Image" "$ARTIFACT_DIR/Image"
else
    echo "ERROR: Buildroot did not produce an ARM64 Image." >&2
    exit 1
fi

for name in hx-h9p-n112.dtb rootfs.cpio.gz; do
    if [ ! -f "$BUILDROOT_DIR/output/images/$name" ]; then
        echo "ERROR: Buildroot did not produce $name." >&2
        find "$BUILDROOT_DIR/output/images" -maxdepth 1 -type f -printf '%f\n' >&2
        exit 1
    fi
    cp "$BUILDROOT_DIR/output/images/$name" "$ARTIFACT_DIR/$name"
done

cp "$BUILDROOT_DIR/.config" "$ARTIFACT_DIR/buildroot.config"
printf 'Buildroot %s\nKernel %s\nProject Sandcastle %s\n' \
    "$BUILDROOT_SHA" "$KERNEL_SHA" "$PROJECTSANDCASTLE_SHA" > "$ARTIFACT_DIR/UPSTREAM_REVISIONS.txt"
(
    cd "$ARTIFACT_DIR"
    sha256sum Image* hx-h9p-n112.dtb rootfs.cpio.gz buildroot.config UPSTREAM_REVISIONS.txt > SHA256SUMS
)

echo "N112 build artifacts created in: $ARTIFACT_DIR"
 "$BUILDROOT_DIR/.config"
grep -q '^BR2_LINUX_KERNEL_INTREE_DTS_NAME="hx/hx-h9p-n112"$' "$BUILDROOT_DIR/.config"

# Re-extract host-m4 so the compatibility patch is applied even on incremental runs.
make -C "$BUILDROOT_DIR" host-m4-dirclean host-fakeroot-dirclean
make -C "$BUILDROOT_DIR" -j"$JOBS" DART_MOBILE_SOURCE_DIR="$ROOT_DIR"

mkdir -p "$ARTIFACT_DIR"
if [ -f "$BUILDROOT_DIR/output/images/Image.gz" ]; then
    cp "$BUILDROOT_DIR/output/images/Image.gz" "$ARTIFACT_DIR/Image.gz"
elif [ -f "$BUILDROOT_DIR/output/images/Image" ]; then
    cp "$BUILDROOT_DIR/output/images/Image" "$ARTIFACT_DIR/Image"
else
    echo "ERROR: Buildroot did not produce an ARM64 Image." >&2
    exit 1
fi

for name in hx-h9p-n112.dtb rootfs.cpio.gz; do
    if [ ! -f "$BUILDROOT_DIR/output/images/$name" ]; then
        echo "ERROR: Buildroot did not produce $name." >&2
        find "$BUILDROOT_DIR/output/images" -maxdepth 1 -type f -printf '%f\n' >&2
        exit 1
    fi
    cp "$BUILDROOT_DIR/output/images/$name" "$ARTIFACT_DIR/$name"
done

cp "$BUILDROOT_DIR/.config" "$ARTIFACT_DIR/buildroot.config"
printf 'Buildroot %s\nKernel %s\nProject Sandcastle %s\n' \
    "$BUILDROOT_SHA" "$KERNEL_SHA" "$PROJECTSANDCASTLE_SHA" > "$ARTIFACT_DIR/UPSTREAM_REVISIONS.txt"
(
    cd "$ARTIFACT_DIR"
    sha256sum Image* hx-h9p-n112.dtb rootfs.cpio.gz buildroot.config UPSTREAM_REVISIONS.txt > SHA256SUMS
)

echo "N112 build artifacts created in: $ARTIFACT_DIR"
