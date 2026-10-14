# noctalia-wallpaper-engine-wrapper

A small `wallpaper` command for running Steam Wallpaper Engine wallpapers on Hyprland (with Noctalia) via [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine).

## Requirements

- [linux-wallpaperengine](https://aur.archlinux.org/packages/linux-wallpaperengine-git) (`paru -S linux-wallpaperengine-git`)
- Wallpaper Engine installed through Steam (for its assets) and some subscribed Workshop wallpapers
- [chafa](https://github.com/hpjansson/chafa) for previews outside kitty
- `fzf`, `jq` and `hyprctl` (Hyprland)

```sh
sudo pacman -S chafa fzf jq
```

## Install

```sh
cp wallpaper ~/.local/bin/
```

Edit `STEAM_LIBS` at the top of the script so it points at your Steam library folders.

To start your last wallpaper at login, add this to your Hyprland autostart:

```lua
hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/wallpaper restore")
```

Or, with a classic `hyprland.conf`:

```
exec-once = ~/.local/bin/wallpaper restore
```

Disable Noctalia's own wallpaper so it doesn't draw over this one.

## Usage

```
wallpaper set <id|name> [--stretch|--clone]  set a wallpaper (name can be partial)
wallpaper select [--stretch|--clone]         pick a wallpaper with arrow keys + Enter
wallpaper get                                show the current wallpaper
wallpaper get <id|name>                      id -> name, or name -> id
wallpaper list, ls                           list downloaded wallpapers (* = current)
wallpaper props [id|name]                    edit wallpaper settings (default: current)
wallpaper restore                            start the saved wallpaper (runs at login)
wallpaper stop                               stop the wallpaper
```

- `--clone` (default) shows the wallpaper on every monitor; `--stretch` spans it across all monitors left to right. The last mode used is remembered.
- Names are case-insensitive; a partial name works if it matches only one wallpaper.
- `select` shows a preview of each wallpaper. In kitty it uses `kitten icat`; in other terminals it uses chafa.
- `props` opens a settings editor: ↑/↓ to move, ←/→ to adjust sliders and options, Enter to toggle (or type an exact slider value / hex color), `r` to reset, Esc to quit. Changes apply live and are saved per wallpaper. Settings that depend on another one only show when it's enabled.
- Settings that hide others (often section headers like "Time notch") show `(N hidden)`; turn them on to reach the real switches underneath.
- The current wallpaper and mode are saved in `~/.config/wallpaper/state`, property overrides in `~/.config/wallpaper/props/<id>.json`; output goes to `~/.cache/wallpaper.log`.

## Custom wallpapers

Any wallpaper folder (with a `project.json`) in `~/.local/share/wallpaper/custom/<id>/` shows up alongside Workshop items, using the folder name as its id.

Some wallpapers rely on scripts linux-wallpaperengine doesn't fully run, so their settings have no effect. The scripts in `custom/` build patched copies instead:

- `custom/mount-fuji-night.sh` — Mount Fuji (3613126158) permanently at night with all widgets (notch, media info, audio visualizer, app dock) removed, plus a "Darkness" slider in `wallpaper props`. Needs `python`.

```sh
custom/mount-fuji-night.sh
wallpaper set mount-fuji-night
```
