#!/usr/bin/env bash

task::run() {
    log "Installing required packages..."
    pkgs=(
        gum
        flatpak
    )

    dnf_install "${pkgs[@]}"
}