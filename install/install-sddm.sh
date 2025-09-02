#!/usr/bin/env bash

task::run() {
    pkgs=(
        sddm
    )

    dnf_install "${pkgs[@]}"

    as_root systemctl enable sddm.service
    as_root systemctl set-default graphical.target
}