#!/usr/bin/env bash
# Battery levels of this machine and of the connected wireless peripherals.
# Fed to the wtf dashboard through a cmdrunner module. Colours are real ANSI
# 256-colour sequences, not tview "[#rrggbb]" tags: cmdrunner runs its output
# through tview.Escape() before rendering it, which neuters the tags, and then
# through TranslateANSI(), which turns these escapes into colour.
#
# macOS exposes a battery percentage only for devices that speak Apple's HID
# battery service: AirPods, Magic Keyboard/Mouse/Trackpad, Apple Pencil. Logitech
# devices (MX Keys S, MX Master 3S) report theirs over the vendor-specific HID++
# protocol instead, which nothing outside Logi Options+ reads, so they show up
# here as "no battery reported" rather than being silently dropped.

set -uo pipefail

GREEN=$'\033[38;5;113m'  # ~#8cc85f
YELLOW=$'\033[38;5;180m' # ~#e3c78a
RED=$'\033[38;5;203m'    # ~#ff5454
FG=$'\033[38;5;251m'     #  #c6c6c6
GRAY=$'\033[38;5;246m'   #  #949494
RESET=$'\033[0m'

bar() { # bar <percent>: 10-cell gauge, coloured by level
  local p=$1 filled i out=""
  filled=$(( (p + 5) / 10 ))
  for ((i = 0; i < 10; i++)); do
    [[ $i -lt $filled ]] && out+="█" || out+="░"
  done
  # Nearest 256-colour cells to Moonfly's green / yellow / red
  local color=$GREEN
  [[ $p -le 40 ]] && color=$YELLOW
  [[ $p -le 15 ]] && color=$RED
  printf '%s%s%s' "$color" "$out" "$RESET"
}

row() { # row <name> <percent|-> [suffix]
  local name=$1 pct=$2 suffix=${3:-}
  if [[ $pct == "-" ]]; then
    printf '  %s%-22s  %s%s\n' "$GRAY" "$name" "no battery reported" "$RESET"
  else
    printf '  %s%-22s%s %s %s%3s%%%s%s%s\n' \
      "$FG" "$name" "$RESET" "$(bar "$pct")" "$FG" "$pct" "$GRAY" "$suffix" "$RESET"
  fi
}

case "$(uname -s)" in
  Darwin)
    # This machine
    pmset -g batt | awk '
      /InternalBattery/ {
        match($0, /[0-9]+%/); pct = substr($0, RSTART, RLENGTH - 1)
        state = ($0 ~ /discharging/) ? "" : ($0 ~ /charging/ ? "  (charging)" : "  (on AC)")
        print pct "\t" state
      }' | while IFS=$'\t' read -r pct state; do
        row "This Mac" "$pct" "$state"
      done

    # Bluetooth peripherals that report through Apple's HID battery service.
    # One ioreg node per device: pair each "Product" with the percentages
    # that follow it before the next product.
    ioreg -r -k BatteryPercent -l 2>/dev/null | awk '
      /"Product" =/          { gsub(/.*= "|"$/, ""); product = $0 }
      /"BatteryPercentLeft"/ { gsub(/[^0-9]/, ""); left = $0 }
      /"BatteryPercentRight"/{ gsub(/[^0-9]/, ""); right = $0 }
      /"BatteryPercentCase"/ { gsub(/[^0-9]/, ""); kase = $0 }
      /"BatteryPercent" =/   { gsub(/[^0-9]/, ""); single = $0 }
      /^\+-o/ && product != "" {
        if (left  != "") print product " L\t" left
        if (right != "") print product " R\t" right
        if (kase  != "") print product " case\t" kase
        if (left == "" && right == "" && single != "") print product "\t" single
        product = ""; left = ""; right = ""; kase = ""; single = ""
      }
      END {
        if (product != "") {
          if (left  != "") print product " L\t" left
          if (right != "") print product " R\t" right
          if (kase  != "") print product " case\t" kase
          if (left == "" && right == "" && single != "") print product "\t" single
        }
      }' | while IFS=$'\t' read -r name pct; do
        row "$name" "$pct"
      done

    # Connected Bluetooth devices macOS knows nothing about, battery-wise.
    system_profiler SPBluetoothDataType -json 2>/dev/null | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)["SPBluetoothDataType"][0].get("device_connected", [])
except Exception:
    sys.exit(0)
for entry in data:
    for name in entry:
        print(name)
' 2>/dev/null | while read -r name; do
        # Skip the ones already printed above with a real percentage
        ioreg -r -k BatteryPercent -l 2>/dev/null | grep -qF "\"$name\"" || row "$name" "-"
      done
    ;;

  Linux)
    command -v upower >/dev/null || { echo "  ${GRAY}upower not installed${RESET}"; exit 0; }
    upower -e | while read -r dev; do
      upower -i "$dev" | awk -v d="$dev" '
        /model:/      { $1 = ""; sub(/^ +/, ""); model = $0 }
        /percentage:/ { gsub(/[^0-9]/, "", $2); pct = $2 }
        /state:/      { state = $2 }
        END {
          if (pct != "" && model != "") {
            suffix = (state == "charging") ? "  (charging)" : (state == "fully-charged" ? "  (full)" : "")
            print model "\t" pct "\t" suffix
          }
        }'
    done | while IFS=$'\t' read -r name pct suffix; do
      row "$name" "$pct" "$suffix"
    done
    ;;
esac
