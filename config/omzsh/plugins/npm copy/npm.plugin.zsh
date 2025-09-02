command -v npm >/dev/null 2>&1 || return
source "$ZSH/plugins/npm/npm.plugin.zsh"

## Update npm global path
export PATH="$HOME/.npm-global/bin:$PATH"

