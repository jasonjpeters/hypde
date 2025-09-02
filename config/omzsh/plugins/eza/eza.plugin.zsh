command -v eza >/dev/null 2>&1 || return
source "$ZSH/plugins/eza/eza.plugin.zsh"

## --- aliases
alias ls='eza -a --icons=always'
alias ll='eza -al --icons=always'
alias lt='eza -a --tree --level=1 --icons=always'