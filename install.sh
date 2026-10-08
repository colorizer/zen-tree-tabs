#!/usr/bin/env bash
# Installs fx-autoconfig (profile side) and links Zen Tree Tabs into a Zen profile.
# Usage: ./install.sh [path/to/zen/profile]
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
zen_root="$HOME/.zen"
zen_install="/opt/zen-browser-bin"

profile="${1:-}"
if [[ -z "$profile" ]]; then
  # The profile the installed Zen actually launches with.
  rel="$(awk -F= '/^Default=/{print $2; exit}' "$zen_root/installs.ini")"
  profile="$zen_root/$rel"
fi
[[ -d "$profile" ]] || { echo "Profile not found: $profile" >&2; exit 1; }
echo "Profile: $profile"

fxac="$repo/vendor/fx-autoconfig"
if [[ ! -d "$fxac" ]]; then
  git clone --depth 1 https://github.com/MrOtherGuy/fx-autoconfig.git "$fxac"
fi

chrome="$profile/chrome"
mkdir -p "$chrome/JS" "$chrome/resources" "$chrome/utils"
cp -r "$fxac/profile/chrome/utils/." "$chrome/utils/"
ln -sfn "$repo/src/zen-tree-tabs.uc.js" "$chrome/JS/zen-tree-tabs.uc.js"
ln -sfn "$repo/src/zen-tree-tabs.css" "$chrome/resources/zen-tree-tabs.css"
rm -f "$chrome/CSS/zen-tree-tabs.uc.css" # Older layout; the script loads its own CSS now.
echo "Profile side installed."

if [[ -f "$zen_install/config.js" ]]; then
  echo "Loader already present in $zen_install."
else
  echo
  echo "One-time loader install into the Zen program directory (needs root):"
  echo "  sudo cp '$fxac/program/config.js' '$zen_install/'"
  echo "  sudo cp '$fxac/program/defaults/pref/config-prefs.js' '$zen_install/defaults/pref/'"
fi
echo
echo "Then restart Zen. Afterwards, edits reload with Ctrl+Alt+Shift+R (no restart,"
echo "no cache clearing). If the script doesn't load at all, open about:support and"
echo "use 'Clear startup cache…' once."
