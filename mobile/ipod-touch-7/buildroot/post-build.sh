#!/bin/sh
set -eu

TARGET_DIR="$1"
SHADOW="$TARGET_DIR/etc/shadow"

if [ ! -f "$SHADOW" ]; then
    echo "ERROR: Buildroot did not create $SHADOW; refusing an image with unknown root authentication." >&2
    exit 1
fi

# The upstream Sandcastle .config uses the public password alpine.
# Lock root in the final target tree; console/SSH access must be configured
# deliberately in a later development build.
sed -i 's/^root:[^:]*:/root:!:/' "$SHADOW"
if ! grep -q '^root:!:' "$SHADOW"; then
    echo "ERROR: failed to lock the root account in the target image." >&2
    exit 1
fi

if [ -e "$TARGET_DIR/etc/init.d/S50dropbear" ]; then
    echo "ERROR: Dropbear startup script is still present." >&2
    exit 1
fi

echo "Darth Mobile post-build checks passed (root locked; no Dropbear startup)."
