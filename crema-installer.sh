#!/usr/bin/env bash
#
# Crema — visual installer (yad GUI front-end).
# A Crema-styled checklist to pick exactly which components to install.
# Everything is user-level; only the optional login screen uses sudo (pkexec).
#
set -euo pipefail
CREMA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CREMA_QUIET=1
# shellcheck source=lib/components.sh
source "$CREMA_ROOT/lib/components.sh"

if ! command -v yad >/dev/null 2>&1; then
  echo "yad is not installed. Use the CLI instead:  ./install.sh --help"
  exit 1
fi

ICON="$CREMA_ROOT/icons/crema-installer.png"
[[ -f "$ICON" ]] || ICON="$CREMA_ROOT/look-and-feel/$LNF_ID/contents/splash/images/logo.svg"
LOGO="$ICON"
# Crema-theme the installer window itself (works even before the GTK theme is Crema).
CSS="$CREMA_ROOT/lib/installer.css"
css_arg=(); [[ -f "$CSS" ]] && css_arg=(--css="$CSS")

# Build checklist rows: CHK  Component  Description  id(hidden)
rows=()
for c in "${COMPONENTS[@]}"; do
  rows+=( "${COMP_DEFAULT[$c]}" "${COMP_LABEL[$c]}" "${COMP_DESC[$c]}" "$c" )
done
# Extra actions as pseudo-rows
rows+=( TRUE  "Apply Crema now"     "Switch the desktop to Crema after installing"        "__apply__" )
rows+=( FALSE "Login screen (SDDM)" "Crema login background — asks for your password"     "__sddm__"  )

set +e
selected="$(yad "${css_arg[@]}" --list --checklist \
  --title "CREMA Desktop Theme Installer" \
  --window-icon="$LOGO" \
  --width=760 --height=560 \
  --text="<b>Crema</b> — espresso desktop theme\nChoose what to install. Everything is user-level and reversible." \
  --column="Install:CHK" --column="Component:TEXT" --column="Description:TEXT" --column="id:HD" \
  --hide-column=4 --print-column=4 --separator="\n" \
  --button="Reset to Default:2" --button="Cancel:1" --button="Install:0" \
  "${rows[@]}")"
rc=$?
set -e

# ---- "Reset to Default" button: safely undo everything Crema installed -------
if [[ $rc -eq 2 ]]; then
  yad "${css_arg[@]}" --question --title="Reset to system default?" \
      --window-icon="$LOGO" --width=520 \
      --text="This removes every file Crema installed and switches your desktop back to the KDE default (<b>Breeze</b>).\n\nIt only changes <b>your</b> user files — nothing system-wide, and no password is needed. Your panel layout is left untouched." \
      --button="Cancel:1" --button="Reset to Default:0" || { echo "Cancelled."; exit 0; }
  {
    echo "# Switching the desktop back to the default (Breeze)…"; crema_unapply || true; echo 40
    echo "# Removing Crema files…"; crema_uninstall "${COMPONENTS[@]}" || true; echo 100
  } | yad "${css_arg[@]}" --progress --auto-close --auto-kill --title="Resetting to default" \
          --window-icon="$LOGO" --width=460 --text="Starting…" --percentage=0
  yad "${css_arg[@]}" --info --title="Reset — done" --width=540 \
      --text="Your desktop has been reset to the system default.\n\n• Login screen (SDDM), if you applied it, reverts separately:\n  <tt>sudo ./sddm/apply-sddm.sh --revert</tt>" \
      --button=OK:0 || true
  exit 0
elif [[ $rc -ne 0 ]]; then
  echo "Cancelled."; exit 0
fi

# Parse selection
todo=(); do_apply=0; do_sddm=0
while IFS= read -r id; do
  [[ -z "$id" ]] && continue
  case "$id" in
    __apply__) do_apply=1 ;;
    __sddm__)  do_sddm=1 ;;
    *) todo+=("$id") ;;
  esac
done <<< "$selected"

if [[ ${#todo[@]} -eq 0 && $do_apply -eq 0 && $do_sddm -eq 0 ]]; then
  yad "${css_arg[@]}" --info --title="Crema" --text="Nothing selected." --button=OK:0
  exit 0
fi

# Run install inside a pulsating progress dialog
{
  n=${#todo[@]}; i=0
  for c in "${todo[@]}"; do
    echo "# Installing ${COMP_LABEL[$c]}…"
    comp_${c}_install || true
    i=$((i+1)); [[ $n -gt 0 ]] && echo $(( i*100/n ))
  done
  if [[ $do_apply -eq 1 ]]; then echo "# Applying Crema…"; crema_apply || true; fi
  echo "100"
} | yad "${css_arg[@]}" --progress --auto-close --auto-kill --title="Installing Crema" \
        --window-icon="$LOGO" --width=460 --text="Starting…" --percentage=0

# Optional login screen (needs root)
sddm_note=""
if [[ $do_sddm -eq 1 ]]; then
  if command -v pkexec >/dev/null 2>&1 && pkexec bash "$CREMA_ROOT/sddm/apply-sddm.sh" >/dev/null 2>&1; then
    sddm_note="\n• Login screen: applied (revert with sudo ./sddm/apply-sddm.sh --revert)."
  else
    sddm_note="\n• Login screen: skipped/failed — run manually:  sudo ./sddm/apply-sddm.sh"
  fi
fi

# Post-install notes for components that need a manual step
notes=""
for c in "${todo[@]}"; do
  case "$c" in
    browser_chromium) notes+="\n• Chromium theme staged at ~/.local/share/crema/chromium-theme — load it via Extensions ▸ Developer mode ▸ Load unpacked." ;;
    browser_firefox)  notes+="\n• Firefox: fully restart the browser to load the Crema chrome." ;;
    fontapply)        notes+="\n• Font: some apps need a restart to pick up Poppins." ;;
  esac
done

yad "${css_arg[@]}" --info --title="Crema — done" --width=540 \
    --text="<b>Installed:</b> ${todo[*]:-（none）}${notes}${sddm_note}\n\nManage anytime with ./install.sh --uninstall." \
    --button=OK:0 || true
