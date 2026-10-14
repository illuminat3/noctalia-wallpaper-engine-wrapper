#!/usr/bin/env bash
# Builds "Mount Fuji (Night, no widgets)" from Workshop item 3613126158.
#
# linux-wallpaperengine doesn't run the scripts this wallpaper uses to switch
# between day and night or to hide its widgets, so this unpacks the scene,
# hides the widget layers and makes the night layer permanently visible.
#
#   custom/mount-fuji-night.sh [path/to/3613126158]

set -euo pipefail

SRC=${1:-/mnt/storage/SteamLibrary/steamapps/workshop/content/431960/3613126158}
OUT="$HOME/.local/share/wallpaper/custom/mount-fuji-night"
HERE=$(dirname "$(realpath "$0")")

# Simple Media (x3), album cover, Media Info (x3), time notch, audio visualizer, app dock
HIDE='[37, 60, 106, 365, 401, 582, 651, 174, 737, 320]'
DAY=893
NIGHT=897

[[ -f $SRC/scene.pkg ]] || { echo "scene.pkg not found in $SRC" >&2; exit 1; }

rm -rf "$OUT"
mkdir -p "$OUT"
python -I "$HERE/../tools/pkg-extract.py" "$SRC/scene.pkg" "$OUT"
cp "$SRC"/preview.* "$OUT"/

jq --argjson hide "$HIDE" --argjson day "$DAY" --argjson night "$NIGHT" '
  .objects as $o
  | def desc($id): [$o[] | select(.parent == $id) | .id] as $k | $k + ([$k[] | desc(.)] | add // []);
  [$hide[] | ., desc(.)[]] as $ids
  | .objects |= map(
      if .id | IN($ids[]) then .visible = false
      elif .id == $day then .visible = false | .alpha = 1
      elif .id == $night then .visible = true | .alpha = 1
      else . end)
' "$OUT/scene.json" >"$OUT/scene.json.tmp"
mv "$OUT/scene.json.tmp" "$OUT/scene.json"

jq '.title = "Mount Fuji (Night, no widgets)" | .file = "scene.json" | del(.workshopid)' \
    "$SRC/project.json" >"$OUT/project.json"

echo "Built $OUT (wallpaper set mount-fuji-night)"
