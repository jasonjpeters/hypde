command -v hellwal >/dev/null 2>&1 || return

if [ -f "${XDG_CACHE_HOME:-$HOME/.cache}/hyprde/colors/variables.sh" ]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/hyprde/colors/variables.sh"
fi

if [ -f "${XDG_CACHE_HOME:-$HOME/.cache}/hyprde/colors/terminal.sh" ]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/hyprde/colors/terminal.sh"
fi
