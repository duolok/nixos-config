#!/usr/bin/env bash

if [[ -n "$TMUX" ]]; then
    target="$(tmux display-message -p -F "#{pane_current_path}")"
    cd "$target" || exit 1
fi

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not inside a git repository"
    exit 1
fi

url=$(git remote get-url origin 2>/dev/null || true)

if [[ $url == *github.com* ]]; then
    if [[ $url == git@* ]]; then
        url="${url#git@}"        
        url="${url/://}"
        url="https://$url"
    fi
    url="${url%.git}"          

    # Cross-platform open
    if command -v open &>/dev/null; then
        open "$url"
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$url"
    else
        echo "Open $url manually"
    fi
else
    echo "This repository is not hosted on GitHub"
fi
