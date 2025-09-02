#!/usr/bin/env bash

task::() {
    grps=(
        libreoffice
        system-tools
        c-development
        development-tools
    )

    for grp in "${grps[@]}"; do
        as_root "$(dnf_cmd)" group install -y "$grp"
    done

    dnf_install @virtualization
}