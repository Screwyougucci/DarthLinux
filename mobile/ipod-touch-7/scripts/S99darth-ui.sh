#!/bin/sh
# SPDX-License-Identifier: MIT
# Start the framebuffer launcher. Touch input is enabled only after hx-touchd
# has started with a locally supplied N112.mtprops file.
set -eu

PIDFILE="/var/run/darth-shell.pid"
READY="/var/run/darth-touch.ready"

start_ui() {
    if [ -s "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
        return 0
    fi
    if [ -r /lib/firmware/multitouch/N112.mtprops ] && [ -e "$READY" ]; then
        i=0
        while [ "$i" -lt 20 ]; do
            if grep -q "Hx Capacitive TouchScreen" /proc/bus/input/devices 2>/dev/null; then
                break
            fi
            sleep 1
            i=$((i + 1))
        done
        if grep -q "Hx Capacitive TouchScreen" /proc/bus/input/devices 2>/dev/null; then
            start-stop-daemon -S -b -m -p "$PIDFILE" \
                --exec /usr/bin/darth-shell -- --fb /dev/fb0 --input auto
            echo "Darth Mobile: framebuffer launcher started with HX touch input."
            return 0
        fi
        echo "Darth Mobile: HX input device was not registered; using static framebuffer mode."
    else
        echo "Darth Mobile: no local N112 firmware; using static framebuffer mode."
    fi
    /usr/bin/darth-shell --fb /dev/fb0
}

stop_ui() {
    start-stop-daemon -K -q -p "$PIDFILE" || true
    rm -f "$PIDFILE"
}

case "${1:-}" in
    start) start_ui ;;
    stop) stop_ui ;;
    restart|reload) stop_ui; start_ui ;;
    *) echo "Usage: $0 {start|stop|restart}" >&2; exit 1 ;;
esac
