#!/usr/bin/env bash

task::run() {

packages=(
    # 1password-beta
    # 1password-cli
    # asdcontrol-git
    # blueberry
    cargo
    clang
    # github-cli
    gnome-calculator
    gnome-keyring
    gnome-themes-extra
    # impala
    # inetutils
    # kdenlive
    # localsend
    
    # man
    # mariadb-libs
    # mise
    # noto-fonts
    # noto-fonts-cjk
    # noto-fonts-emoji
    # noto-fonts-extra
    
    # obsidian
    pinta
    # postgresql-libs
    # python-gobject
    # python-poetry-core
    # python-terminaltexteffects
    # qt5-wayland
    # signal-desktop
    # spotify
    # starship
    # ttf-cascadia-mono-nerd
    # ttf-ia-writer
    # ttf-jetbrains-mono-nerd
    # typora
    # tzupdate
    # walker-bi
    # wiremix
    # wl-clip-persist
    # woff2-font-aw
    # imagemagick
    yaru-icon-theme
    # wl-screenrec
)

    # output file
    outfile="pkg-check.txt"

    # clear old file
    > "$outfile"

    # loop through packages
    for pkg in "${packages[@]}"; do
        if dnf list --available "$pkg" >/dev/null 2>&1; then
            echo "$pkg yes" >> "$outfile"
        else
            echo "$pkg no" >> "$outfile"
        fi
    done

}