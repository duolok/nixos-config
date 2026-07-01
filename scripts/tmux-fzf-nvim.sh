#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/skim-themes.sh"

selected=$(fd . "$HOME" --type=f \
    | fzf "${SKIM_THEME_BASE[@]}" --scheme=path)

[[ ! $selected ]] && exit 0

file_dir=$(dirname "$selected")
file_name=$(basename "$selected")

tmux neww -n "$file_name" -c "$file_dir" "$(printf 'nvim %q' "$selected")"
