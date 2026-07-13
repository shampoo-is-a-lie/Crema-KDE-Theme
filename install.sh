#!/usr/bin/env bash
#
# Crema theme installer for KDE Plasma 6 (CLI front-end).
#
# Installs entirely into your user home ($XDG_DATA_HOME, ~/.config).
# It NEVER touches system files, needs no root, and is fully reversible.
# Copy this whole folder to any machine and run ./install.sh
#
# Usage:
#   ./install.sh                 Install the default component set
#   ./install.sh --all           Install every component
#   ./install.sh --only=a,b,c    Install only these components
#   ./install.sh --font          Also set Poppins as the interface font
#   ./install.sh --apply         Apply the Crema theme after installing
#   ./install.sh --gui           Launch the visual installer (yad)
#   ./install.sh --list          List component ids
#   ./install.sh --uninstall     Remove everything (or with --only a,b)
#   ./install.sh --help
#
# Login screen (SDDM) is applied separately with sudo: ./sddm/apply-sddm.sh
#
set -euo pipefail
CREMA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/components.sh
source "$CREMA_ROOT/lib/components.sh"

APPLY=0 UNINSTALL=0 WANT_FONT=0 ALL=0 ONLY="" GUI=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --font) WANT_FONT=1 ;;
    --all) ALL=1 ;;
    --only=*) ONLY="${arg#--only=}" ;;
    --gui) GUI=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --list) printf '%s\n' "${COMPONENTS[@]}"; exit 0 ;;
    --help|-h) sed -n '3,24p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg (try --help)"; exit 1 ;;
  esac
done

if [[ $GUI -eq 1 ]]; then exec "$CREMA_ROOT/crema-installer.sh"; fi

# Resolve the component selection.
selection=()
if [[ -n "$ONLY" ]]; then
  IFS=',' read -ra selection <<< "$ONLY"
elif [[ $ALL -eq 1 ]]; then
  selection=("${COMPONENTS[@]}")
else
  for c in "${COMPONENTS[@]}"; do [[ "${COMP_DEFAULT[$c]}" == TRUE ]] && selection+=("$c"); done
  [[ $WANT_FONT -eq 1 ]] && selection+=(fontapply)
fi

if [[ $UNINSTALL -eq 1 ]]; then
  cinfo "Removing Crema components..."
  crema_uninstall "${selection[@]}"
  cinfo "Done. If Crema was applied, pick another Global Theme in System Settings to switch away."
  echo "(Login screen, if applied, reverts with: sudo ./sddm/apply-sddm.sh --revert)"
  exit 0
fi

crema_install "${selection[@]}"
[[ $APPLY -eq 1 ]] && crema_apply

echo
cinfo "Crema installed: ${selection[*]}"
if [[ $APPLY -eq 0 ]]; then
  cat <<EOF

  Apply it with:  ./install.sh --apply     (or pick "Crema" in System Settings > Global Theme)
  Visual installer:  ./install.sh --gui
  Login screen (sudo):  sudo ./sddm/apply-sddm.sh
EOF
fi
