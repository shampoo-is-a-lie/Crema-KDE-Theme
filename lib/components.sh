#!/usr/bin/env bash
# Crema — component library. Sourced by install.sh (CLI) and crema-installer.sh (GUI).
# The caller must set CREMA_ROOT to the repo root before sourcing.
[[ -n "${_CREMA_COMPONENTS_SOURCED:-}" ]] && return 0
_CREMA_COMPONENTS_SOURCED=1

: "${CREMA_ROOT:?set CREMA_ROOT to the repo root before sourcing components.sh}"

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
CONF_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
COLOR_DIR="$DATA_HOME/color-schemes"
LNF_DIR="$DATA_HOME/plasma/look-and-feel"
DESKTOPTHEME_DIR="$DATA_HOME/plasma/desktoptheme"
KONSOLE_DIR="$DATA_HOME/konsole"
EDITOR_DIR="$DATA_HOME/org.kde.syntax-highlighting/themes"
FONT_DIR="$DATA_HOME/fonts/Crema"
STAGE_DIR="$DATA_HOME/crema"
LNF_ID="com.cafeneurotico.crema.desktop"

# Logging: respects CREMA_QUIET=1 (used by the GUI, which shows its own progress).
cinfo() { [[ "${CREMA_QUIET:-0}" == 1 ]] || printf '\033[38;2;212;163;115m==>\033[0m %s\n' "$*"; }

# Back up a file once before we overwrite it (so uninstall can restore it).
# These always return 0 so they never trip `set -e` when the file is absent.
_backup_once() { local f="$1"; if [[ -f "$f" && ! -f "$f.pre-crema.bak" ]]; then cp "$f" "$f.pre-crema.bak"; fi; return 0; }
_restore()     { local f="$1"; if [[ -f "$f.pre-crema.bak" ]]; then mv "$f.pre-crema.bak" "$f"; else rm -f "$f"; fi; return 0; }

# ---- Registry ---------------------------------------------------------------
# Order matters (install order). GUI/CLI iterate this list.
COMPONENTS=(colorscheme globaltheme desktoptheme konsole editor obs fonts fontapply gtk browser_chromium browser_firefox launcher)
declare -A COMP_LABEL COMP_DESC COMP_DEFAULT
COMP_LABEL[colorscheme]="Color scheme";        COMP_DEFAULT[colorscheme]=TRUE
COMP_DESC[colorscheme]="Crema palette for Plasma and all Qt/KDE apps"
COMP_LABEL[globaltheme]="Global Theme";         COMP_DEFAULT[globaltheme]=TRUE
COMP_DESC[globaltheme]="The selectable 'Crema' Global Theme (+ splash screen)"
COMP_LABEL[desktoptheme]="Plasma desktop theme"; COMP_DEFAULT[desktoptheme]=TRUE
COMP_DESC[desktoptheme]="Pinned-Crema Plasma style (panels, popups)"
COMP_LABEL[konsole]="Konsole / Yakuake";        COMP_DEFAULT[konsole]=TRUE
COMP_DESC[konsole]="Terminal color scheme + profile, set as the default"
COMP_LABEL[editor]="Editor syntax theme";       COMP_DEFAULT[editor]=TRUE
COMP_DESC[editor]="Crema colors for Kate / KWrite / KDevelop"
COMP_LABEL[obs]="OBS Studio";                   COMP_DEFAULT[obs]=TRUE
COMP_DESC[obs]="Crema variant theme for OBS (Settings > Appearance > Crema)"
COMP_LABEL[fonts]="Bundled fonts";              COMP_DEFAULT[fonts]=TRUE
COMP_DESC[fonts]="Install the Poppins font family"
COMP_LABEL[fontapply]="Set Poppins as UI font"; COMP_DEFAULT[fontapply]=FALSE
COMP_DESC[fontapply]="Use Poppins for the interface (titlebar SemiBold); backs up kdeglobals"
COMP_LABEL[gtk]="GTK apps";                     COMP_DEFAULT[gtk]=TRUE
COMP_DESC[gtk]="GTK4/libadwaita Crema colors (+ let Flatpaks read them). GTK3 is automatic."
COMP_LABEL[browser_chromium]="Chromium browsers"; COMP_DEFAULT[browser_chromium]=FALSE
COMP_DESC[browser_chromium]="Set the built-in 'Orange' dark theme in Chrome/Brave/Chromium (close them first)"
COMP_LABEL[browser_firefox]="Firefox";          COMP_DEFAULT[browser_firefox]=FALSE
COMP_DESC[browser_firefox]="Apply a Crema userChrome.css to your Firefox profiles"
COMP_LABEL[launcher]="App-menu launcher";       COMP_DEFAULT[launcher]=TRUE
COMP_DESC[launcher]="Add 'CREMA Desktop Theme Installer' to your application menu (clickable)"

# ---- Components -------------------------------------------------------------
comp_colorscheme_install() {
  cinfo "Color scheme -> $COLOR_DIR/Crema.colors"
  mkdir -p "$COLOR_DIR"; cp "$CREMA_ROOT/color-schemes/Crema.colors" "$COLOR_DIR/"
}
comp_colorscheme_uninstall() { rm -f "$COLOR_DIR/Crema.colors"; }

comp_globaltheme_install() {
  cinfo "Global Theme -> $LNF_DIR/$LNF_ID"
  mkdir -p "$LNF_DIR"; rm -rf "$LNF_DIR/$LNF_ID"
  cp -r "$CREMA_ROOT/look-and-feel/$LNF_ID" "$LNF_DIR/"
}
comp_globaltheme_uninstall() { rm -rf "$LNF_DIR/$LNF_ID"; }

comp_desktoptheme_install() {
  cinfo "Plasma desktop theme -> $DESKTOPTHEME_DIR/Crema"
  mkdir -p "$DESKTOPTHEME_DIR"; rm -rf "$DESKTOPTHEME_DIR/Crema"
  cp -r "$CREMA_ROOT/desktoptheme/Crema" "$DESKTOPTHEME_DIR/"
}
comp_desktoptheme_uninstall() { rm -rf "$DESKTOPTHEME_DIR/Crema"; }

comp_konsole_install() {
  cinfo "Konsole scheme + profile (set as default)"
  mkdir -p "$KONSOLE_DIR"
  cp "$CREMA_ROOT/konsole/Crema.colorscheme" "$CREMA_ROOT/konsole/Crema.profile" "$KONSOLE_DIR/"
  if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile "Crema.profile"
    command -v yakuake >/dev/null 2>&1 && \
      kwriteconfig6 --file yakuakerc --group "Desktop Entry" --key DefaultProfile "Crema.profile" || true
  fi
}
comp_konsole_uninstall() {
  rm -f "$KONSOLE_DIR/Crema.colorscheme" "$KONSOLE_DIR/Crema.profile"
  if command -v kreadconfig6 >/dev/null 2>&1; then
    [[ "$(kreadconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile 2>/dev/null)" == "Crema.profile" ]] && \
      kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile "" || true
  fi
}

comp_editor_install() {
  cinfo "Editor syntax theme -> $EDITOR_DIR/crema.theme"
  mkdir -p "$EDITOR_DIR"; cp "$CREMA_ROOT/editor/crema.theme" "$EDITOR_DIR/"
}
comp_editor_uninstall() { rm -f "$EDITOR_DIR/crema.theme"; }

comp_obs_install() {
  # OBS 30+ variant theme (.ovt). Install to whichever OBS config dir exists.
  local base done=0
  for base in "$CONF_HOME/obs-studio" "$HOME/.var/app/com.obsproject.Studio/config/obs-studio"; do
    [[ -d "$base" ]] || continue
    mkdir -p "$base/themes"; cp "$CREMA_ROOT/obs/Crema.ovt" "$base/themes/"; done=1
    cinfo "OBS theme -> $base/themes/Crema.ovt"
  done
  [[ $done -eq 1 ]] || cinfo "OBS config not found (open OBS once, then re-run --only=obs)"
}
comp_obs_uninstall() {
  local base
  for base in "$CONF_HOME/obs-studio" "$HOME/.var/app/com.obsproject.Studio/config/obs-studio"; do
    rm -f "$base/themes/Crema.ovt"
  done
}

comp_fonts_install() {
  cinfo "Poppins fonts -> $FONT_DIR"
  mkdir -p "$FONT_DIR"; cp "$CREMA_ROOT"/fonts/*.ttf "$FONT_DIR/"
  fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
}
comp_fonts_uninstall() { rm -rf "$FONT_DIR"; fc-cache -f "$DATA_HOME/fonts" >/dev/null 2>&1 || true; }

comp_fontapply_install() {
  command -v kwriteconfig6 >/dev/null 2>&1 || { cinfo "kwriteconfig6 missing; skipping font apply"; return; }
  _backup_once "$CONF_HOME/kdeglobals"
  cinfo "Setting Poppins as the interface font (titlebar SemiBold)"
  local reg="Poppins,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
  local tb="Poppins,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
  local sm="Poppins,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
  local ti="Poppins,10,-1,5,600,0,0,0,0,0,0,0,0,0,0,1,SemiBold,0,0"
  kwriteconfig6 --file kdeglobals --group General --key font "$reg"
  kwriteconfig6 --file kdeglobals --group General --key menuFont "$reg"
  kwriteconfig6 --file kdeglobals --group General --key toolBarFont "$tb"
  kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont "$sm"
  kwriteconfig6 --file kdeglobals --group WM --key activeFont "$ti"
}
comp_fontapply_uninstall() { _restore "$CONF_HOME/kdeglobals"; }

comp_gtk_install() {
  # Augment (never overwrite) gtk.css: Plasma's own gtk.css imports colors.css
  # and kde_window_geometry.css (GTK4 window shadows) which we must preserve.
  cinfo "GTK4/libadwaita colors -> $CONF_HOME/gtk-4.0/crema.css"
  mkdir -p "$CONF_HOME/gtk-4.0"
  cp "$CREMA_ROOT/gtk/crema.css" "$CONF_HOME/gtk-4.0/crema.css"
  local g="$CONF_HOME/gtk-4.0/gtk.css"
  _backup_once "$g"; touch "$g"
  # import ours last so libadwaita named-color overrides win
  grep -q "@import 'crema.css';" "$g" 2>/dev/null || printf "@import 'crema.css';\n" >> "$g"
  if command -v flatpak >/dev/null 2>&1; then
    flatpak override --user --filesystem=xdg-config/gtk-4.0:ro --filesystem=xdg-config/gtk-3.0:ro >/dev/null 2>&1 \
      && cinfo "Granted Flatpak apps read access to your GTK config" || true
  fi
}
comp_gtk_uninstall() {
  rm -f "$CONF_HOME/gtk-4.0/crema.css"
  local g="$CONF_HOME/gtk-4.0/gtk.css"
  if [[ -f "$g.pre-crema.bak" ]]; then
    mv "$g.pre-crema.bak" "$g"
  elif [[ -f "$g" ]]; then
    sed -i "/@import 'crema.css';/d" "$g"; [[ -s "$g" ]] || rm -f "$g"
  fi
  command -v flatpak >/dev/null 2>&1 && \
    flatpak override --user --nofilesystem=xdg-config/gtk-4.0 --nofilesystem=xdg-config/gtk-3.0 >/dev/null 2>&1 || true
}

_CHROMIUM_UDS=(
  "$HOME/.var/app/com.google.Chrome/config/google-chrome|com.google.Chrome"
  "$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser|com.brave.Browser"
  "$HOME/.var/app/io.github.ungoogled_software.ungoogled_chromium/config/chromium|ungoogled_chromium"
  "$HOME/.config/google-chrome|google-chrome"
  "$HOME/.config/chromium|chromium"
  "$HOME/.config/BraveSoftware/Brave-Browser|brave"
)
comp_browser_chromium_install() {
  # Set the built-in "Orange" dark theme by writing the Preferences theme block.
  # Works for Flatpak (no managed policy needed). Skips running browsers, since
  # Chromium rewrites Preferences on exit and would lose the change.
  local frag="$CREMA_ROOT/browsers/chrome-theme.json" setter="$CREMA_ROOT/browsers/set-chrome-theme.py"
  local e ud pat pref applied=0 skipped=""
  for e in "${_CHROMIUM_UDS[@]}"; do
    ud="${e%%|*}"; pat="${e##*|}"; pref="$ud/Default/Preferences"
    [[ -f "$pref" ]] || continue
    if pgrep -f "$pat" >/dev/null 2>&1; then skipped+=" ${pat}"; continue; fi
    python3 "$setter" apply "$pref" "$frag" && { cinfo "Orange theme -> ${pref/#$HOME/\~}"; applied=$((applied+1)); }
  done
  [[ -n "$skipped" ]] && cinfo "skipped (running — close them & re-run --only=browser_chromium):$skipped"
  [[ $applied -gt 0 || -n "$skipped" ]] || cinfo "no Chrome/Brave/Chromium profile found (open it once, then re-run)"
}
comp_browser_chromium_uninstall() {
  local setter="$CREMA_ROOT/browsers/set-chrome-theme.py" e pref
  for e in "${_CHROMIUM_UDS[@]}"; do
    pref="${e%%|*}/Default/Preferences"
    [[ -f "$pref" ]] && ! pgrep -f "${e##*|}" >/dev/null 2>&1 && python3 "$setter" reset "$pref" 2>/dev/null || true
  done
}

comp_browser_firefox_install() {
  local css="$CREMA_ROOT/browsers/firefox/userChrome.css" applied=0 root prof base
  for base in "$HOME/.mozilla/firefox" "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"; do
    [[ -d "$base" ]] || continue
    for prof in "$base"/*/; do
      [[ -f "$prof/prefs.js" || -f "$prof/times.json" ]] || continue
      mkdir -p "$prof/chrome"
      cp "$css" "$prof/chrome/userChrome.css"
      # enable custom stylesheets via user.js (idempotent)
      touch "$prof/user.js"
      grep -q 'legacyUserProfileCustomizations.stylesheets' "$prof/user.js" 2>/dev/null || \
        printf 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);\n' >> "$prof/user.js"
      applied=$((applied+1))
    done
  done
  if [[ $applied -gt 0 ]]; then
    cinfo "Applied Crema userChrome.css to $applied Firefox profile(s). Fully restart Firefox to see it."
  else
    cinfo "No Firefox profile found (open Firefox once first, then re-run)."
  fi
}
comp_browser_firefox_uninstall() {
  local base prof
  for base in "$HOME/.mozilla/firefox" "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"; do
    [[ -d "$base" ]] || continue
    for prof in "$base"/*/; do rm -f "$prof/chrome/userChrome.css"; done
  done
}

comp_launcher_install() {
  local appdir="$DATA_HOME/applications" desktop="$DATA_HOME/applications/crema-installer.desktop"
  local icon="$CREMA_ROOT/icons/crema-installer.png"
  cinfo "App-menu launcher -> $desktop"
  mkdir -p "$appdir"
  cat > "$desktop" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=CREMA Desktop Theme Installer
GenericName=Desktop Theme Installer
Comment=Install the Crema espresso desktop theme
Exec="$CREMA_ROOT/crema-installer.sh"
Icon=$icon
Terminal=false
Categories=Settings;DesktopSettings;
Keywords=crema;theme;espresso;coffee;
EOF
  chmod +x "$desktop"
  command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$appdir" >/dev/null 2>&1 || true
  # Also drop a clickable icon on the Desktop, if there is one.
  local deskdir; deskdir="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
  if [[ -d "$deskdir" ]]; then
    cp "$desktop" "$deskdir/crema-installer.desktop"; chmod +x "$deskdir/crema-installer.desktop"
    cinfo "Desktop icon -> $deskdir/crema-installer.desktop (first click: choose 'Trust & run')"
  fi
}
comp_launcher_uninstall() {
  rm -f "$DATA_HOME/applications/crema-installer.desktop"
  local deskdir; deskdir="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
  rm -f "$deskdir/crema-installer.desktop"
}

# ---- Actions (not artifacts; handled separately by front-ends) --------------
crema_apply() {
  cinfo "Applying Crema..."
  command -v plasma-apply-lookandfeel  >/dev/null 2>&1 && plasma-apply-lookandfeel -a "$LNF_ID" >/dev/null 2>&1 || true
  command -v plasma-apply-colorscheme  >/dev/null 2>&1 && plasma-apply-colorscheme Crema >/dev/null 2>&1 || true
  command -v plasma-apply-desktoptheme >/dev/null 2>&1 && plasma-apply-desktoptheme Crema >/dev/null 2>&1 || true
}

# Switch the live desktop back to the stock KDE default (Breeze). This only
# rewrites the current user's Plasma appearance settings (~/.config) — exactly
# what picking a Global Theme in System Settings does. It touches no system
# files, needs no root, and does NOT reset your panel/widget layout (we never
# pass --resetLayout). Every call is guarded so a missing tool is a no-op.
crema_unapply() {
  cinfo "Switching the desktop back to the system default (Breeze)..."
  command -v plasma-apply-lookandfeel  >/dev/null 2>&1 && plasma-apply-lookandfeel -a org.kde.breeze.desktop >/dev/null 2>&1 || true
  command -v plasma-apply-colorscheme  >/dev/null 2>&1 && { plasma-apply-colorscheme BreezeLight >/dev/null 2>&1 || plasma-apply-colorscheme BreezeDark >/dev/null 2>&1; } || true
  command -v plasma-apply-desktoptheme >/dev/null 2>&1 && { plasma-apply-desktoptheme default >/dev/null 2>&1 || plasma-apply-desktoptheme breeze >/dev/null 2>&1; } || true
}

# Full safe reset: return the desktop to default, then remove every Crema
# artifact (restoring any file we backed up). Strictly user-level — it never
# touches system files and never needs root. The login screen (SDDM), if it was
# applied, is a system file and reverts separately: sudo ./sddm/apply-sddm.sh --revert
crema_reset() {
  crema_unapply
  crema_uninstall "${COMPONENTS[@]}"
}

# ---- Drivers ----------------------------------------------------------------
crema_valid() { local c; for c in "${COMPONENTS[@]}"; do [[ "$c" == "$1" ]] && return 0; done; return 1; }
crema_install()   { local c; for c in "$@"; do crema_valid "$c" && { comp_${c}_install   || cinfo "warning: component '$c' reported an error"; }; done; return 0; }
crema_uninstall() { local c; for c in "$@"; do crema_valid "$c" && { comp_${c}_uninstall || cinfo "warning: uninstall '$c' reported an error"; }; done; return 0; }
