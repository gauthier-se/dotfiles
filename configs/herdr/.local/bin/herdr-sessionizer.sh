#!/bin/bash

# 1. List projects in ~/repos (flat layout: repos/<project>)
selected=$(fd --type d --max-depth 1 --hidden . ~/repos | fzf)

# If we exit fzf without choosing anything, stop the script
if [[ -z $selected ]]; then
    exit 0
fi

# 2. Reuse the project's workspace, or create it
selected_name=$(basename "$selected")
workspace=$(herdr workspace list | jq -r --arg name "$selected_name" \
    'first(.result.workspaces[] | select(.label == $name) | .workspace_id) // empty')

if [[ -n $workspace ]]; then
    herdr workspace focus "$workspace"
else
    herdr workspace create --cwd "$selected" --label "$selected_name" --focus
fi
