#!/usr/bin/env bash
# shellcheck disable=SC2088

# -----------------------------------------------------
# PATH / Defaults
# -----------------------------------------------------
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
HYPRDE_CACHE="$XDG_CACHE_HOME/hyprde"

default=""
current="$HYPRDE_CACHE/wallpaper/current"
blurred="$HYPRDE_CACHE/wallpaper/blurred.png"
squared="$HYPRDE_CACHE/wallpaper/squared.png"

mkdir -p "$HYPRDE_CACHE/colors" "$HYPRDE_CACHE/wallpaper"

[[ -f "$current" ]] || : > "$current"
[[ -f "$HYPRDE_CACHE/wallpaper/current.rasi" ]] || : > "$HYPRDE_CACHE/wallpaper/current.rasi"

# -----------------------------------------------------
# Tunables
# -----------------------------------------------------
EM_PX=16
BLUR_EM_W=56
BLUR_EM_H=35
BLUR_SIGMA=6
SQUARE_PX=1024
PNG_COMPR=1

# -----------------------------------------------------
# Functions
# -----------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }

resolve_wallpaper() {
    local arg="${1-}" path
    path="$default"
    
    [[ -z $arg || $arg == restore ]] && [[ -s $current ]] && { IFS= read -r path <"$current"; }
    [[ -n $arg && $arg != restore ]] && path="$arg"
    [[ ${path:0:2} == "~/" ]] && path="${path/#\~/$HOME}"
    [[ -f $path ]] || path="$default"
    
    printf '%s' "$path"
}

set_per_monitor() {
    local wallpaper="$1"
    
    hyprctl monitors 2>/dev/null \
    | awk '/^Monitor /{print $2}' \
    | while read -r monitor; do
        hyprctl hyprpaper wallpaper "$monitor,$wallpaper" >/dev/null 2>&1 || true
    done
}

set_hyprpaper() {
    local wallpaper="$1"
    [[ -n "$wallpaper" && -f "$wallpaper" ]] || return 1
    
    
    if ! pgrep -x hyprpaper >/dev/null 2>&1; then
        (hyprpaper & disown)
    fi
    
    local i ok=0
    
    for i in {1..20}; do
        if hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1; then
            ok=1; break
        fi
        
        sleep 0.1
    done
    
    [[ $ok -eq 1 ]] || return 1
    
    
    if ! hyprctl hyprpaper wallpaper ",$wallpaper" >/dev/null 2>&1; then
        set_per_monitor "$wallpaper"
    fi
    return 0
}

make_blurred() {
    local tw=$(( BLUR_EM_W * EM_PX ))
    local th=$(( BLUR_EM_H * EM_PX ))
    local tmp_in="$HYPRDE_CACHE/wallpaper/.blur_tmp.png"
    local tmp_out="$HYPRDE_CACHE/wallpaper/.blur_out.png"
    
    vipsthumbnail "$1" --size "${tw}x${th}" --crop centre --eprofile sRGB \
    -o "$tmp_in[compression=$PNG_COMPR]" >/dev/null 2>&1
    
    vips gaussblur "$tmp_in" "$tmp_out" "$BLUR_SIGMA" >/dev/null 2>&1
    
    mv -f "$tmp_out" "$blurred"
    rm -f "$tmp_in"
}



make_squared() {
    local out="$HYPRDE_CACHE/wallpaper/.square_out.png"
    
    vipsthumbnail "$1" --size "${SQUARE_PX}x${SQUARE_PX}" --crop centre --eprofile sRGB \
    -o "$out[compression=$PNG_COMPR]" >/dev/null 2>&1
    
    mv -f "$out" "$squared"
}

# -----------------------------------------------------
# Main
# -----------------------------------------------------
mode=${1:-}
wallpaper="$(resolve_wallpaper "$mode")"

# Bail if only restoring
# don't try to set an empty/nonexistent wallpaper
if [[ -z "$wallpaper" || ! -f "$wallpaper" ]]; then
    # nothing to restore; bail quietly
    exit 0
fi

set_hyprpaper "$wallpaper"

if [[ "$mode" == "restore" ]]; then
    if [[ -f "$blurred" ]]; then
        printf '* { current-image: url("%s", height); }\n' "$blurred" > "$HYPRDE_CACHE/wallpaper/current.rasi"
    else
        # fallback to the actual wallpaper if no blurred yet
        printf '* { current-image: url("%s", height); }\n' "$wallpaper" > "$HYPRDE_CACHE/wallpaper/current.rasi"
    fi
    exit 0
fi

prev="$(/usr/bin/cat "$current" 2>/dev/null || true)"

if [[ "$prev" == "$wallpaper" ]] \
&& [[ -f "$blurred" && -f "$squared" ]] \
&& [[ "$blurred" -nt "$wallpaper" && "$squared" -nt "$wallpaper" ]]; then
    printf '* { current-image: url("%s", height); }\n' "$blurred" > "$HYPRDE_CACHE/wallpaper/current.rasi"
    exit 0
fi

printf '%s' "$wallpaper" > "$current"

hellwal -i "$wallpaper" -m -d -o "$HYPRDE_CACHE/colors/" || true

make_blurred "$wallpaper"
make_squared "$wallpaper"

printf '* { current-image: url("%s", height); }\n' "$blurred" > "$HYPRDE_CACHE/wallpaper/current.rasi"
