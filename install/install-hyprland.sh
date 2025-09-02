#!/usr/bin/env bash

task::run() {
    pkgs=(
        grimblast
        hdrop
        hyprcursor
        hyprcursor-devel
        hyprdim
        hypre
        hypre-devel
        hypre-mpich
        hypre-mpich-devel
        hypre-openmpi
        hypre-openmpi-devel
        hyprgraphics
        hyprgraphics-devel
        hypridle
        hyprland
        hyprland-autoname-workspaces
        hyprland-contrib
        hyprland-devel
        hyprland-plugin-borders-plus-plus
        hyprland-plugin-csgo-vulkan-fix
        hyprland-plugin-hyprbars
        hyprland-plugin-hyprexpo
        hyprland-plugin-hyprfocus
        hyprland-plugin-hyprscrolling
        hyprland-plugin-hyprtrails
        hyprland-plugin-hyprwinwrap
        hyprland-plugin-xtra-dispatchers
        hyprland-plugins
        hyprland-protocols-devel
        hyprland-qt-support
        hyprland-qtutils
        hyprland-uwsm
        hyprlang
        hyprlang-devel
        hyprlock
        hyprnome
        hyprpaper
        hyprpicker
        hyprpolkitagent
        hyprprop
        hyprqt6engine
        hyprshot
        hyprsunset
        hyprsysteminfo
        hyprutils
        hyprutils-devel
        hyprwayland-scanner-devel
        pyprland
        shellevents
        waypaper
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
    )

    dnf_install "${pkgs[@]}"

    hyprpm update

    ## --- Add hy3 plugin

    noansi() { sed -r 's/\x1B\[[0-9;]*[mK]//g'; }   # strip ANSI colors

    hy3_block() {
    hyprpm list \
        | noansi \
        | sed -n '/Plugin[[:space:]]\+hy3\b/,/^[[:space:]]*$/p'
    }

    hy3_installed() { 
        hyprpm list | noansi | grep -qiE '^Plugin[[:space:]]+hy3\b'
    }

    hy3_enabled() {
        hy3_block | grep -qiE 'enabled[[:space:]]*:[[:space:]]*true'
    }

    if ! hy3_installed; then
        log "hy3 not installed, adding…"
        yes | hyprpm add https://github.com/outfoxxed/hy3 >/dev/null 2>&1 || true
    fi

    if ! hy3_enabled; then
        log "hy3 installed but not enabled, enabling…"
        hyprpm enable hy3 >/dev/null 2>&1 || true
    fi    
}