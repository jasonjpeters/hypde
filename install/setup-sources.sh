#!/usr/bin/env bash

task::run() {

    ## --- Flatpak: Flathub
    if ! flatpak remotes --system | grep -Fxq flathub; then
        log "Adding flathub remote"
        as_root flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi

    ## --- solopasha/hyprland copr
    copr_enable "solopasha/hyprland"

    ## --- errornointernet/quickshell copr
    copr_enable "errornointernet/quickshell"

    ## --- alternateved/eza copr
    copr_enable "alternateved/eza"

    ## --- atim/lazydocker copr
    copr_enable "atim/lazydocker"

    ## --- dejan/lazygit copr
    copr_enable "dejan/lazygit"

    ## --- agriffis/neovim-nightly copr
    copr_enable "agriffis/neovim-nightly" 
}