#!/usr/bin/env bash
# Launcher for the wtf dashboard (alias: dash).
#
# wtfutil 0.50.0 expands neither "~" nor "$HOME" in module paths: cmdrunner runs
# its command through exec, not a shell, and the git module hands its paths
# straight to git. Absolute paths are unavoidable, and they differ between macOS
# (/Users/segau) and NixOS (/home/segau), so the config in the repo carries an
# @HOME@ placeholder and this script resolves it at launch into a cache copy.
#
# The real ~/.config/wtf/ is left alone on purpose: wtf writes the todo list
# there, and that belongs to the machine, not to the repo.

set -euo pipefail

src="$HOME/dotfiles/configs/wtf/config.yml"
out="${XDG_CACHE_HOME:-$HOME/.cache}/wtf/config.yml"

mkdir -p "$(dirname "$out")"
sed "s|@HOME@|$HOME|g" "$src" > "$out"

exec wtfutil --config="$out" "$@"
