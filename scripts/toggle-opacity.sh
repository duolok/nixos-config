#!/usr/bin/env bash
state="${XDG_RUNTIME_DIR:-/tmp}/sway-opacity"
if [ -f "$state" ] && grep -q low "$state"; then
    swaymsg opacity 1
    echo full > "$state"
else
    swaymsg opacity 0.8
    echo low > "$state"
fi
