#!/usr/bin/env bash

set -euo pipefail

readonly target_workspace=10
readonly startup_settle_seconds=2
readonly lock_dir="${XDG_RUNTIME_DIR:-/tmp}/second-monitor-workspace.lock"
declare -A known_monitors=()

if ! mkdir "$lock_dir" 2>/dev/null; then
    exit 0
fi

trap 'rmdir "$lock_dir"' EXIT

lua_quote() {
    local value=$1

    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    printf '"%s"' "$value"
}

get_monitors() {
    hyprctl -j monitors 2>/dev/null | jq -r 'sort_by(.x, .y, .id) | .[].name'
}

get_target_monitor() {
    local monitor

    monitor=$(
        hyprctl -j monitors 2>/dev/null \
            | jq -r '[sort_by(.x, .y, .id)[] | select(.name | test("^(eDP|LVDS|DSI)") | not)][0].name // empty'
    )

    if [[ -n $monitor ]]; then
        printf '%s\n' "$monitor"
        return
    fi

    hyprctl -j monitors 2>/dev/null | jq -r 'sort_by(.x, .y, .id) | .[1].name // empty'
}

show_workspace_on() {
    local target_monitor=$1
    local focused_monitor
    local quoted_monitor
    local quoted_focused_monitor

    focused_monitor=$(hyprctl -j activeworkspace 2>/dev/null | jq -r '.monitor // empty')
    quoted_monitor=$(lua_quote "$target_monitor")

    hyprctl --quiet dispatch "hl.dsp.focus({ monitor = $quoted_monitor })"
    hyprctl --quiet dispatch "hl.dsp.focus({ workspace = $target_workspace })"

    if [[ -n $focused_monitor && $focused_monitor != "$target_monitor" ]]; then
        quoted_focused_monitor=$(lua_quote "$focused_monitor")
        hyprctl --quiet dispatch "hl.dsp.focus({ monitor = $quoted_focused_monitor })"
    fi
}

sleep "$startup_settle_seconds"

mapfile -t monitors < <(get_monitors)
for monitor in "${monitors[@]}"; do
    known_monitors["$monitor"]=1
done

# Also apply the rule when Hyprland starts with two monitors already connected.
if ((${#monitors[@]} >= 2)); then
    target_monitor=$(get_target_monitor)
    if [[ -n $target_monitor ]]; then
        show_workspace_on "$target_monitor"
    fi
fi

while sleep 1; do
    mapfile -t monitors < <(get_monitors)

    if ((${#monitors[@]} >= 2)); then
        for monitor in "${monitors[@]}"; do
            if [[ ! -v known_monitors["$monitor"] ]]; then
                target_monitor=$(get_target_monitor)
                if [[ -n $target_monitor ]]; then
                    show_workspace_on "$target_monitor"
                fi
                break
            fi
        done
    fi

    known_monitors=()
    for monitor in "${monitors[@]}"; do
        known_monitors["$monitor"]=1
    done
done
