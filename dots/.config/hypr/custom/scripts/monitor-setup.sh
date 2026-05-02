#!/usr/bin/env bash

MONITOR_ORDER=(
    "eDP-1"
    "DP-1"
    "HDMI-A-1"
)

INTERNAL_MONITOR="eDP-1"

# ---

MONITORS_JSON=$(hyprctl monitors all -j)

get_preferred_mode() {
    echo "$MONITORS_JSON" | jq -r \
        --arg name "$1" \
        '.[] | select(.name == $name) | .availableModes[0]' \
        | sed 's/Hz//'
}

get_width() {
    echo "$MONITORS_JSON" | jq -r \
        --arg name "$1" \
        '.[] | select(.name == $name) | .availableModes[0]' \
        | grep -oP '^\d+'
}

is_connected() {
    echo "$MONITORS_JSON" | jq -e \
        --arg name "$1" \
        '.[] | select(.name == $name)' > /dev/null 2>&1
}

is_lid_closed() {
    local state
    state=$(cat /proc/acpi/button/lid/*/state 2>/dev/null | awk '{print $2}')
    [ "$state" = "closed" ]
}

# ---

X_OFFSET=0

for monitor in "${MONITOR_ORDER[@]}"; do
    if ! is_connected "$monitor"; then
        hyprctl keyword monitor "$monitor, disable" 2>/dev/null
        continue
    fi

    if [ "$monitor" = "$INTERNAL_MONITOR" ] && is_lid_closed; then
        hyprctl keyword monitor "$monitor, disable"
        continue
    fi

    mode=$(get_preferred_mode "$monitor")
    width=$(get_width "$monitor")

    echo "Setting: $monitor  mode=$mode  offset=${X_OFFSET}x0"
    hyprctl keyword monitor "$monitor, $mode, ${X_OFFSET}x0, 1"

    X_OFFSET=$(( X_OFFSET + width ))
done