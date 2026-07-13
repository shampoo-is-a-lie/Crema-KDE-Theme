#!/usr/bin/env bash
#
# Crema SDDM login — applies a Crema background over the existing, tested
# breeze-fedora greeter (the theme already active on this Bazzite system).
#
# This is the ONLY part of Crema that touches a system dir, so it needs root
# and is kept separate from the user-level install.sh.
#
# SAFETY: this only changes the login *background image* — not the greeter
# QML — so it cannot break login. If the image ever fails to load, breeze
# just shows its default background and login still works.
#
# Usage:
#   sudo ./sddm/apply-sddm.sh            apply Crema login background
#   sudo ./sddm/apply-sddm.sh --revert   restore your previous background
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="/var/sddm_themes/themes/01-breeze-fedora"
BAK="$THEME_DIR/theme.conf.user.pre-crema.bak"

if [[ "${1:-}" == "--revert" ]]; then
  if [[ -f "$BAK" ]]; then
    cp "$BAK" "$THEME_DIR/theme.conf.user"
    rm -f "$THEME_DIR/crema-login.jpg"
    echo "Reverted to your previous SDDM background (theme.conf.user restored)."
  else
    echo "No backup found ($BAK). Nothing to revert."
    echo "You can re-select a background in System Settings > Colors & Themes > Login Screen (SDDM)."
  fi
  exit 0
fi

if [[ $EUID -ne 0 ]]; then
  echo "This touches $THEME_DIR (system dir) — please run with sudo:"
  echo "    sudo $0"
  exit 1
fi

[[ -d "$THEME_DIR" ]] || { echo "Expected theme dir not found: $THEME_DIR"; echo "Is the active SDDM theme still 01-breeze-fedora? Check /etc/sddm.conf.d/kde_settings.conf"; exit 1; }

# Back up the current config once, so --revert can restore it.
if [[ -f "$THEME_DIR/theme.conf.user" && ! -f "$BAK" ]]; then
  cp "$THEME_DIR/theme.conf.user" "$BAK"
  echo "Backed up current theme.conf.user -> $(basename "$BAK")"
fi

install -m 0644 "$SCRIPT_DIR/crema-login.jpg" "$THEME_DIR/crema-login.jpg"
install -m 0644 "$SCRIPT_DIR/theme.conf.user" "$THEME_DIR/theme.conf.user"

echo "Crema login background applied to 01-breeze-fedora."
echo "See it: log out (or reboot). Revert anytime with:  sudo $0 --revert"
