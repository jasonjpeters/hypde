#!/usr/bin/env bash
set -euo pipefail

task::run() {
    : "${XDG_CONFIG_HOME:=${HOME}/.config}"
    : "${XDG_DATA_HOME:=${HOME}/.local/share}"
    : "${HYPRDE_DIR:=${XDG_DATA_HOME}/hyprde}"   # fallback if not set
    
    local SRC_DIR="${HYPRDE_DIR}/defaults/xdg"
    local XDG_PROFILE="/etc/profile.d/xdg.sh"
    local XDG_DEFAULTS="/etc/xdg/user-dirs.defaults"
    local XDG_CONF="/etc/xdg/user-dirs.conf"
    
    _log() { printf '[xdg] %s\n' "$*"; }
    
    # Copy if missing (idempotent) — runs with root privileges
    _install_if_absent() {
        local src="$1" dst="$2" mode="${3:-0644}"
        if [[ -f "$dst" ]]; then
            _log "keep $dst"
        else
            as_root install -Dm"$mode" "$src" "$dst"
            _log "installed $dst"
        fi
    }
    
    _init_for_current_user() {
        export XDG_CONFIG_HOME XDG_DATA_HOME
        export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
        export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
        export XDG_PROJECTS_DIR="${XDG_PROJECTS_DIR:-$HOME/Projects}"
        
        mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME" "$XDG_PROJECTS_DIR"
        
        # Create ~/.config/user-dirs.dirs if missing and sync folders
        xdg-user-dirs-update
        
        local user_dirs_file="$XDG_CONFIG_HOME/user-dirs.dirs"

        # Ensure XDG_PROJECTS_DIR is present in user-dirs.dirs (idempotent)
        if [[ -f "$user_dirs_file" ]]; then
            if ! grep -q '^XDG_PROJECTS_DIR=' "$user_dirs_file"; then
                printf 'XDG_PROJECTS_DIR="$HOME/Projects"\n' >> "$user_dirs_file"
                _log "added XDG_PROJECTS_DIR to $user_dirs_file"
            fi
        fi

        if [[ -f "$user_dirs_file" ]]; then
            while IFS== read -r key val; do
                [[ "$key" == XDG_*_DIR ]] || continue
                dir="${val%\"}"; dir="${dir#\"}"
                dir="${dir/\$HOME/$HOME}"
                [[ -d "$dir" ]] || mkdir -p "$dir"
            done < "$user_dirs_file"
        fi
    }
    
    # Needs root to switch user
    _init_for_user() {
        local u="$1"
        as_root runuser -u "$u" -- bash -lc "$(declare -f _init_for_current_user); _init_for_current_user"
    }
    
    _log "configure system defaults"
    
    # Ensure parent dirs exist (root)
    as_root install -d /etc/profile.d
    as_root install -d /etc/xdg
    
    _install_if_absent "$SRC_DIR/xdg.sh"             "$XDG_PROFILE"   0644
    _install_if_absent "$SRC_DIR/user-dirs.defaults" "$XDG_DEFAULTS"  0644
    _install_if_absent "$SRC_DIR/user-dirs.conf"     "$XDG_CONF"      0644
    
    _log "system XDG done"
    
    # Optional per-user init
    case "${1:-}" in
        --user)
            _init_for_user "${2:-}"
        ;;
        "")
            # Running as a regular user → init current user
            if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
                _init_for_current_user
            fi
        ;;
    esac
}
