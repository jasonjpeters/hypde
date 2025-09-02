#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC1090

set -eE

HYPRDE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HYPRDE_DIR/lib/common.sh"
. "$HYPRDE_DIR/lib/dnf.sh"
. "$HYPRDE_DIR/lib/flatpak.sh"
. "$HYPRDE_DIR/lib/webapp.sh"

HYPRDE_INSTALL="$HYPRDE_DIR/install"
export PATH="$HYPRDE_DIR/bin:$PATH"


TASKS=()
while IFS= read -r line || [[ -n "$line" ]]; do
    ## --- Skip comments / blank lines
    [[ "$line" =~ ^[[:space:]]*$ || "$line" =~ ^[[:space:]]*# ]] && continue
    TASKS+=("$(echo "$line" | xargs)")
done <"$HYPRDE_DIR/install.tasks"

for task in "${TASKS[@]}"; do
    task_file=$"$HYPRDE_INSTALL/$task.sh"
    [[ -f "$task_file" ]] || die "Unknown task: $task"
    . "$task_file"
    log ">>> TASK: $task"
    task::run
done