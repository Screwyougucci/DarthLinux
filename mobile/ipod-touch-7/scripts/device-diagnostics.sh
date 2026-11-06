#!/bin/sh
# Read-only hardware inventory for Darth Linux Mobile bring-up.
set -u

section() {
    printf '\n===== %s =====\n' "$1"
}

section "IDENTITY"
uname -a
printf 'cmdline: '
cat /proc/cmdline 2>/dev/null || echo unavailable
if [ -r /proc/device-tree/model ]; then
    printf 'device-tree model: '
    tr '\000' ' ' < /proc/device-tree/model
    printf '\n'
fi
if [ -r /proc/device-tree/compatible ]; then
    printf 'device-tree compatible: '
    tr '\000' ' ' < /proc/device-tree/compatible
    printf '\n'
fi

section "FRAMEBUFFER"
for f in /sys/class/graphics/fb0/name /sys/class/graphics/fb0/virtual_size /sys/class/graphics/fb0/bits_per_pixel /sys/class/graphics/fb0/stride; do
    if [ -r "$f" ]; then printf '%s: ' "$f"; cat "$f"; fi
done
ls -l /dev/fb* 2>/dev/null || echo "No framebuffer device node."

section "INPUT DEVICES"
if [ -r /proc/bus/input/devices ]; then
    cat /proc/bus/input/devices
else
    echo "No input-device inventory."
fi
ls -l /dev/input/event* 2>/dev/null || echo "No evdev event nodes."

section "GPU / DRM"
ls -la /dev/dri 2>/dev/null || echo "No DRM device directory."
ls -la /sys/class/drm 2>/dev/null || echo "No DRM class entries."

section "AUDIO"
ls -la /dev/snd 2>/dev/null || echo "No ALSA device directory."
ls -la /sys/class/sound 2>/dev/null || echo "No sound class entries."

section "CAMERA / MEDIA"
ls -l /dev/video* /dev/media* 2>/dev/null || echo "No V4L2/media device nodes."

section "STORAGE SAFETY"
mount 2>/dev/null | grep -E ' /hostfs | / ' || true
if mount 2>/dev/null | grep -E ' /hostfs .*\bro\b' >/dev/null; then
    echo "PASS: /hostfs is mounted read-only."
else
    echo "WARN: /hostfs is not confirmed read-only or is not mounted."
fi

section "RELEVANT KERNEL LOGS"
dmesg 2>/dev/null | grep -Ei 'hx|touch|framebuffer|simplefb|drm|gpu|snd|audio|camera|isp|mipi|nvme|apfs' | tail -n 160 || true

section "END"
echo "This report is read-only. It does not probe registers, write storage, or change device settings."
