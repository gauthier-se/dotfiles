#!/usr/bin/env bash
# Hyprland behaviours AeroSpace has no option for, driven by its event stream.
#   dwindle   from the third window on, a new window splits the one before it,
#             so the split direction alternates
#   fallback  closing the last window of a workspace goes back to the most
#             recently used workspace that still has windows
#
# Started by after-startup-command, ends when the AeroSpace server quits.
set -uo pipefail

recent=""         # workspace names, most recently focused first
last_window=""    # focus before the current event, tells a close from a switch
last_workspace=""

remember_workspace() {
    local name kept=$1
    for name in $recent; do
        [ "$name" = "$1" ] || kept="$kept $name"
    done
    recent=$kept
}

dwindle() {
    local window=$1 workspace=$2 windows
    windows=$(aerospace list-windows --workspace "$workspace" --format '%{window-id} %{window-layout}')
    # The second window stays a plain sibling: joining it would only rotate the root
    [ "$(grep -c tiles <<<"$windows")" -gt 2 ] || return 0
    case $(awk -v id="$window" '$1 == id { print $2 }' <<<"$windows") in
        h_tiles) aerospace join-with --window-id "$window" left ;;
        v_tiles) aerospace join-with --window-id "$window" up ;;
    esac
}

leave_emptied_workspace() {
    local workspace=$1 window=$2 nonempty name
    # macOS may hand the focus to another app by itself, let that settle first
    sleep 0.1
    [ "$(aerospace list-workspaces --focused)" = "$workspace" ] || return 0
    [ "$(aerospace list-windows --workspace focused --count)" -eq 0 ] || return 0
    # A window sent away with move-node-to-workspace still exists: stay here
    aerospace list-windows --all --format '%{window-id}' | grep -qx "$window" && return 0

    nonempty=$(aerospace list-workspaces --monitor focused --empty no)
    for name in $recent $nonempty; do
        if grep -qx "$name" <<<"$nonempty"; then
            aerospace workspace "$name"
            return
        fi
    done
}

aerospace subscribe focus-changed focused-workspace-changed window-detected |
    jq --unbuffered -r '[._event, .workspace, (.windowId // "")] | @tsv' |
    while IFS=$'\t' read -r event workspace window; do
        case $event in
            window-detected) dwindle "$window" "$workspace" ;;
            focused-workspace-changed) remember_workspace "$workspace" ;;
            focus-changed)
                if [ -z "$window" ] && [ -n "$last_window" ] && [ "$workspace" = "$last_workspace" ]; then
                    leave_emptied_workspace "$workspace" "$last_window"
                fi
                last_window=$window
                last_workspace=$workspace
                ;;
        esac
    done
