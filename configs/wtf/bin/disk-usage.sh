#!/usr/bin/env bash
# Disk usage of the volumes that actually matter, in a form that reads the same
# on macOS (APFS container) and on NixOS (/ plus the Nix store if it is split).
# Fed to the wtf dashboard through a cmdrunner module.

set -uo pipefail

mounts=("/")
[[ "$(uname -s)" == "Darwin" ]] && mounts+=("/System/Volumes/Data")
[[ -d /nix ]] && mountpoint -q /nix 2>/dev/null && mounts+=("/nix")

df -h "${mounts[@]}" 2>/dev/null | awk \
  -v green="$(printf '\033[38;5;113m')" \
  -v yellow="$(printf '\033[38;5;180m')" \
  -v red="$(printf '\033[38;5;203m')" \
  -v fg="$(printf '\033[38;5;251m')" \
  -v gray="$(printf '\033[38;5;246m')" \
  -v reset="$(printf '\033[0m')" '
  NR == 1 { next }
  {
    # df columns differ between BSD and GNU; the mount point is always last.
    # Capacity is the FIRST field ending in %: on BSD, %iused follows it and
    # would otherwise win.
    mount = $NF
    for (i = 1; i <= NF; i++) if ($i ~ /%$/) { pctf = $i; pct = $i + 0; break }
    color = green
    if (pct >= 80) color = yellow
    if (pct >= 90) color = red
    printf "  %s%-22s%s %s%5s%s  %s%s free of %s%s\n", \
      fg, mount, reset, color, pctf, reset, gray, $4, $2, reset
  }'
