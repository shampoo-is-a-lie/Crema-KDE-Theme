#!/usr/bin/env bash
#
# Crema theme installer for KDE Plasma 6
#
# Installs entirely into your user home ($XDG_DATA_HOME, ~/.config).
# It NEVER touches system files, needs no root, and is fully reversible.
# Copy this whole folder to any machine and run ./install.sh
#
# Usage:
#   ./install.sh              Install theme files (does not change your desktop)
#   ./install.sh --apply      Install, then apply the Crema global theme now
#   ./install.sh --font       Also set Poppins as the interface font (backed up)
#   ./install.sh --uninstall  Remove everything this script installed
#   ./install.sh --help
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
CONF_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
COLOR_DIR="$DATA_HOME/color-schemes"
LNF_DIR="$DATA_HOME/plasma/look-and-feel"
DESKTOPTHEME_DIR="$DATA_HOME/plasma/desktoptheme"
KONSOLE_DIR="$DATA_HOME/konsole"
EDITOR_DIR="$DATA_HOME/org.kde.syntax-highlighting/themes"
FONT_DIR="$DATA_HOME/fonts/Crema"
LNF_ID="com.cafeneurotico.crema.desktop"

APPLY=0; SET_FONT=0; UNINSTALL=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --font) SET_FONT=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --help|-h)
      sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg (try --help)"; exit 1 ;;
  esac
done

info() { printf '\033[38;2;212;163;115m==>\033[0m %s\n' "$*"; }

if [[ $UNINSTALL -eq 1 ]]; then
  info "Removing Crema theme files..."
  rm -f  "$COLOR_DIR/Crema.colors"
  rm -rf "$LNF_DIR/$LNF_ID"
  rm -rf "$DESKTOPTHEME_DIR/Crema"
  rm -f  "$KONSOLE_DIR/Crema.colorscheme" "$KONSOLE_DIR/Crema.profile"
  rm -f  "$EDITOR_DIR/crema.theme"
  rm -rf "$FONT_DIR"
  fc-cache -f "$DATA_HOME/fonts" >/dev/null 2>&1 || true
  info "Done. Crema files removed."
  info "If Crema was applied, pick another Global Theme in System Settings to switch away."
  exit 0
fi

# --- Install theme files -----------------------------------------------------
info "Installing color scheme -> $COLOR_DIR/Crema.colors"
mkdir -p "$COLOR_DIR"
cp "$SCRIPT_DIR/color-schemes/Crema.colors" "$COLOR_DIR/"

info "Installing global theme -> $LNF_DIR/$LNF_ID"
mkdir -p "$LNF_DIR"
rm -rf "$LNF_DIR/$LNF_ID"
cp -r "$SCRIPT_DIR/look-and-feel/$LNF_ID" "$LNF_DIR/"

info "Installing Plasma desktop theme -> $DESKTOPTHEME_DIR/Crema"
mkdir -p "$DESKTOPTHEME_DIR"
rm -rf "$DESKTOPTHEME_DIR/Crema"
cp -r "$SCRIPT_DIR/desktoptheme/Crema" "$DESKTOPTHEME_DIR/"

info "Installing Konsole scheme + profile -> $KONSOLE_DIR"
mkdir -p "$KONSOLE_DIR"
cp "$SCRIPT_DIR/konsole/Crema.colorscheme" "$SCRIPT_DIR/konsole/Crema.profile" "$KONSOLE_DIR/"

info "Installing editor (KSyntaxHighlighting) theme -> $EDITOR_DIR/crema.theme"
mkdir -p "$EDITOR_DIR"
cp "$SCRIPT_DIR/editor/crema.theme" "$EDITOR_DIR/"

info "Installing Poppins fonts -> $FONT_DIR"
mkdir -p "$FONT_DIR"
cp "$SCRIPT_DIR"/fonts/*.ttf "$FONT_DIR/"
fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true

# --- Optional: set Poppins as the interface font -----------------------------
if [[ $SET_FONT -eq 1 ]]; then
  if command -v kwriteconfig6 >/dev/null 2>&1; then
    BACKUP="$CONF_HOME/kdeglobals.crema-fontbackup"
    if [[ -f "$CONF_HOME/kdeglobals" && ! -f "$BACKUP" ]]; then
      cp "$CONF_HOME/kdeglobals" "$BACKUP"
      info "Backed up kdeglobals -> $BACKUP"
    fi
    # Preset font strings match what Plasma 6 writes; titlebar is Poppins SemiBold (weight 600).
    reg="Poppins,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
    toolbar="Poppins,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
    small="Poppins,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
    title="Poppins,10,-1,5,600,0,0,0,0,0,0,0,0,0,0,1,SemiBold,0,0"
    kwriteconfig6 --file kdeglobals --group General --key font "$reg"
    kwriteconfig6 --file kdeglobals --group General --key menuFont "$reg"
    kwriteconfig6 --file kdeglobals --group General --key toolBarFont "$toolbar"
    kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont "$small"
    kwriteconfig6 --file kdeglobals --group WM --key activeFont "$title"
    info "Set Poppins as the interface font (titlebar SemiBold; fixed-width font left unchanged)."
  else
    info "kwriteconfig6 not found; skipping font setup."
  fi
fi

# --- Optional: apply now -----------------------------------------------------
if [[ $APPLY -eq 1 ]]; then
  if command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
    info "Applying Crema global theme..."
    plasma-apply-lookandfeel -a "$LNF_ID" || {
      info "plasma-apply-lookandfeel failed; try applying from System Settings."
    }
  elif command -v lookandfeeltool >/dev/null 2>&1; then
    lookandfeeltool -a "$LNF_ID" || true
  fi
  command -v plasma-apply-colorscheme >/dev/null 2>&1 && plasma-apply-colorscheme Crema || true
  command -v plasma-apply-desktoptheme >/dev/null 2>&1 && plasma-apply-desktoptheme Crema || true
fi

echo
info "Crema installed."
if [[ $APPLY -eq 0 ]]; then
  cat <<EOF

  To apply it, either run:
      ./install.sh --apply            (add --font to also switch to Poppins)
  or open  System Settings > Colors & Themes > Global Theme  and pick "Crema".

  The color scheme alone also appears under  Colors & Themes > Colors  as "Crema".
EOF
fi
