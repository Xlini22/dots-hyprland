#!/usr/bin/env bash

set -u

readonly target_workspace=10
declare -A known_monitors=()

get_monitors() {
    hyprctl -j monitors 2>/dev/null | jq -r '.[].name'
}

show_workspace_on() {
    local target_monitor=$1
    local focused_monitor

    focused_monitor=$(hyprctl -j activeworkspace 2>/dev/null | jq -r '.monitor // empty')

    hyprctl --quiet dispatch focusmonitor "$target_monitor"
    hyprctl --quiet dispatch workspace "$target_workspace"

    if [[ -n $focused_monitor && $focused_monitor != "$target_monitor" ]]; then
        hyprctl --quiet dispatch focusmonitor "$focused_monitor"
    fi
}

mapfile -t monitors < <(get_monitors)
for monitor in "${monitors[@]}"; do
    known_monitors["$monitor"]=1
done

# Also apply the rule when Hyprland starts with two monitors already connected.
if ((${#monitors[@]} == 2)); then
    show_workspace_on "${monitors[1]}"
fi

while sleep 1; do
    mapfile -t monitors < <(get_monitors)

    if ((${#monitors[@]} == 2)); then
        for monitor in "${monitors[@]}"; do
            if [[ ! -v known_monitors["$monitor"] ]]; then
                show_workspace_on "$monitor"
                break
            fi
        done
    fi

    known_monitors=()
    for monitor in "${monitors[@]}"; do
        known_monitors["$monitor"]=1
    done
done
