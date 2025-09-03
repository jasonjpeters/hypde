#!/usr/bin/env bash

# -----------------------------------------------------
# Create cache folder
# -----------------------------------------------------
wallpaper_cache="${XDG_CACHE_HOME:-$HOME/.cache}/hyprde/wallpaper"

if [ ! -d "$wallpaper_cache" ]; then
    mkdir -p "$wallpaper_cache"
fi

# -----------------------------------------------------
# Get selected wallpaper
# -----------------------------------------------------
default="$HOME/.local/share/hyprde/defaults/wallpaper/wallpaper001.jpg"
current="$wallpaper_cache/current"

if [ -z "$1" ]; then
    if [ -f "$current" ]; then
        wallpaper=$(cat "$current")
    else
        wallpaper=$default
    fi
else
    wallpaper=$1
fi

if [ ! -f "$current" ]; then
    touch "$current"
fi

echo "$wallpaper" > "$current"

# -----------------------------------------------------
# Create blurred wallpaper
# -----------------------------------------------------
blurred="$wallpaper_cache/blurred.png"

magick "$wallpaper" -resize 75% "$blurred"
magick "$blurred" -blue "50x30" "$blurred"

# -----------------------------------------------------
# Created square wallpaper
# -----------------------------------------------------
squared="$wallpaper_cache/square.png"

magick "$wallpaper" -gravity Center -extent 1:1 "$squared"


# -----------------------------------------------------
# Create rasi file
# -----------------------------------------------------
rasi="$wallpaper_cache/current.rasi"

if [ ! -f "$rasi" ]; then
    touch "$rasi"
fi

echo "* { current-image: url(\"$blurred\", height); }" >"$rasi"