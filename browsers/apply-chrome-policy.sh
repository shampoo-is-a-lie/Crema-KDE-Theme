#!/usr/bin/env bash
#
# Crema — Chrome/Chromium theming the "Omarchy" way: a BrowserThemeColor managed
# policy + an instant --refresh-platform-policy. This recolors the whole browser
# cohesively and applies in real time.
#
# IMPORTANT: managed policies live under /etc (system dir) and are read only by
# NATIVE Chromium/Chrome/Brave/Edge. FLATPAK browsers are sandboxed and cannot
# read them (flatpak issue #4709), so this cannot theme a Flatpak Chrome. For a
# Flatpak setup use Brave with Qt theming, or install a native Chromium.
#
# Usage:
#   sudo ./browsers/apply-chrome-policy.sh            apply Crema seed (#2C1E16)
#   sudo ./browsers/apply-chrome-policy.sh "#432818"  apply a custom seed color
#   sudo ./browsers/apply-chrome-policy.sh --revert    remove the Crema policy
#
set -euo pipefail

SEED="${1:-#2C1E16}"     # Crema espresso; Chrome derives a matching palette
REVERT=0; [[ "${1:-}" == "--revert" ]] && REVERT=1

# native browser -> its /etc managed-policy dir and candidate binaries
declare -A DIR=(
  [chromium]=/etc/chromium/policies/managed
  [chrome]=/etc/opt/chrome/policies/managed
  [brave]=/etc/brave/policies/managed
  [edge]=/etc/opt/edge/policies/managed
)
declare -A BIN=(
  [chromium]="chromium chromium-browser"
  [chrome]="google-chrome google-chrome-stable"
  [brave]="brave brave-browser brave-origin"
  [edge]="microsoft-edge microsoft-edge-stable"
)

# Warn about any Flatpak browsers (can't be themed this way)
if command -v flatpak >/dev/null 2>&1; then
  fb=$(flatpak list --app 2>/dev/null | grep -iE "chrome|chromium|brave|edge" || true)
  [[ -n "$fb" ]] && echo "note: Flatpak browsers detected — this policy will NOT affect them:
$fb
"
fi

if [[ $EUID -ne 0 ]]; then
  echo "Managed policies live under /etc — run with sudo:  sudo $0 ${*:-}"
  exit 1
fi

found=0
for b in "${!DIR[@]}"; do
  bin=""; for c in ${BIN[$b]}; do command -v "$c" >/dev/null 2>&1 && { bin="$c"; break; }; done
  [[ -n "$bin" ]] || continue
  found=1
  if [[ $REVERT -eq 1 ]]; then
    rm -f "${DIR[$b]}/color.json"
    echo "reverted: $b"
  else
    mkdir -p "${DIR[$b]}"
    printf '{\n  "BrowserThemeColor": "%s",\n  "BrowserColorScheme": "device"\n}\n' "$SEED" > "${DIR[$b]}/color.json"
    echo "themed: $b  ($SEED)  -> ${DIR[$b]}/color.json"
    # instant apply if it is running
    sudo -u "${SUDO_USER:-$USER}" "$bin" --refresh-platform-policy --no-startup-window >/dev/null 2>&1 || true
  fi
done

[[ $found -eq 1 ]] || echo "No native Chromium/Chrome/Brave/Edge found. (Flatpak browsers can't use policies.)"
