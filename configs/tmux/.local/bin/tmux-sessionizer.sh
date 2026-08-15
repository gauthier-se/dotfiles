#!/bin/bash

# 1. List projects in ~/repos (flat layout: repos/<project>)
selected=$(find ~/repos -mindepth 1 -maxdepth 1 -type d | fzf)

# If we exit fzf without choosing anything, stop the script
if [[ -z $selected ]]; then
    exit 0
fi

# 2. Clean the directory name for Tmux
selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# 3. Session creation/connection logic
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name
