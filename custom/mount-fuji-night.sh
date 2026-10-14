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
  # Black overlay over the whole scene, its opacity driven by the "darkness" property
  | .general.orthogonalprojection as $size
  | .objects += [{
      id: 99999, name: "Darkness overlay", image: "models/util/solidlayer.json",
      origin: "\($size.width / 2) \($size.height / 2) 0", size: "\($size.width) \($size.height)",
      angles: "0 0 0", scale: "1 1 1", color: "0 0 0", colorBlendMode: 0,
      alpha: {user: "darkness", value: 0}, visible: true
    }]
' "$OUT/scene.json" >"$OUT/scene.json.tmp"
mv "$OUT/scene.json.tmp" "$OUT/scene.json"

jq '.title = "Mount Fuji (Night, no widgets)" | .file = "scene.json" | del(.workshopid)
    | .general.properties.darkness = {
        order: -1, text: "Darkness", type: "slider", value: 0, min: 0, max: 0.9, step: 0.05, precision: 2, fraction: true
      }' \
    "$SRC/project.json" >"$OUT/project.json"

echo "Built $OUT (wallpaper set mount-fuji-night)"
