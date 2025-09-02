#!/usr/bin/env bash
# shellcheck disable=SC2088
# shellcheck disable=SC2016

task::run() {
    command -v as_root >/dev/null 2>&1 || {
        log "as_root helper not found on PATH"
        return 1
    }
    command -v zsh >/dev/null 2>&1 || {
        log "zsh not found on PATH"
        return 1
    }
    command -v curl >/dev/null 2>&1 || {
        log "curl not found on PATH"
        return 1
    }

    local ZDOT="$HOME/.zshrc"
    local desired='source "$HOME/.config/omzsh/rc"'

    if [[ -e "$ZDOT" ]]; then
        # replace if it's not exactly our one-liner
        if ! grep -qxF "$desired" "$ZDOT" 2>/dev/null || [[ $(wc -l <"$ZDOT") -ne 1 ]]; then
            local STATE_BASE="${XDG_STATE_HOME:-$HOME/.local/state}"
            local RUN_ID="${HYPRDE_BACKUP_RUN_ID:-$(date +%Y%m%d-%H%M%S)}"
            local BROOT="${HYPRDE_BACKUP_DIR:-$STATE_BASE/HYPRDE/backups}/$RUN_ID/home/${USER}"
            mkdir -p "$BROOT"
            cp -a "$ZDOT" "$BROOT/.zshrc"
            log "backup: $ZDOT -> $BROOT/.zshrc"

            printf '%s\n' "$desired" >"$ZDOT"
            log "wrote shim to $ZDOT"
        else
            log "~/.zshrc already shims to .config/omzsh/rc"
        fi
    else
        printf '%s\n' "$desired" >"$ZDOT"
        log "created shim $ZDOT"
    fi

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        RUNZSH=no CHSH=yes KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
            -- --unattended --keep-zshrc
        log "oh-my-zsh installed"
    else
        log "~/.oh-my-zsh already present; skipping installer"
    fi

    # ensure default shell is zsh (fully unattended via as_root)
    local current_shell zsh_path
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    zsh_path="$(command -v zsh)"

    # Ensure zsh is registered in /etc/shells (required by chsh on many distros)
    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
        if as_root sh -c "grep -qxF '$zsh_path' /etc/shells || printf '%s\n' '$zsh_path' >> /etc/shells"; then
            log "added $zsh_path to /etc/shells"
        else
            log "failed to add $zsh_path to /etc/shells"
            return 1
        fi
    fi

    if [[ "$current_shell" != "$zsh_path" ]]; then
        if as_root chsh -s "$zsh_path" "$USER"; then
            log "default shell updated to zsh ($zsh_path)"
        else
            log "failed to update default shell with chsh"
            return 1
        fi
    else
        log "default shell already set to zsh"
    fi

    ## --- zsh autosuggestions
    if [[ ! -d "$HOME/.config/omzsh/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.config/omzsh/plugins/zsh-autosuggestions"
    fi

    ## --- zsh syntax highlighting
    if [[ ! -d "$HOME/.config/omzsh/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.config/omzsh/plugins/zsh-syntax-highlighting"
    fi

    ## --- fast syntax highlighting
    if [[ ! -d "$HOME/.config/omzsh/plugins/fast-syntax-highlighting" ]]; then
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$HOME/.config/omzsh/plugins/fast-syntax-highlighting"
    fi
}
