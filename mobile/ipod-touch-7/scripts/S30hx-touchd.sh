#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# Darth Mobile wrapper for the upstream Corellium hx-touchd service.
set -eu

FW_LOCAL="/lib/firmware/multitouch/N112.mtprops"
FWLIST="/etc/hw/hx-touch.fwlist"
PIDFILE="/var/run/hx-touchd.pid"
READY="/var/run/darth-touch.ready"

start_touchd() {
    if [ ! -r "$FW_LOCAL" ]; then
        echo "Darth Mobile: N112.mtprops is unavailable; skipping HX touch initialization."
        rm -f "$READY"
        return 0
    fi
    if [ ! -r "$FWLIST" ]; then
        echo "Darth Mobile: HX firmware list is missing; skipping touch initialization."
        rm -f "$READY"
        return 0
    fi
    # The initramfs contains the locally extracted firmware. Do not mount or
    # read the iOS APFS volume to obtain it.
    sed -i "s|/hostfs/usr/share/firmware/multitouch/N112.mtprops|$FW_LOCAL|g" "$FWLIST"
    start-stop-daemon -S -b -m -p "$PIDFILE" \
        --exec /usr/bin/hx-touchd -- "$FWLIST" /dev/nvme0n3
    sleep 1
    if [ -s "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
        : > "$READY"
        echo "Darth Mobile: hx-touchd process started."
    else
        rm -f "$PIDFILE" "$READY"
        echo "Darth Mobile: hx-touchd did not remain running; touch will be disabled."
    fi
}

stop_touchd() {
    start-stop-daemon -K -q -p "$PIDFILE" || true
    rm -f "$PIDFILE" "$READY"
}

case "${1:-}" in
    start) start_touchd ;;
    stop) stop_touchd ;;
    restart|reload) stop_touchd; start_touchd ;;
    *) echo "Usage: $0 {start|stop|restart}" >&2; exit 1 ;;
esac
