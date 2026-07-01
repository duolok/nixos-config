#!/usr/bin/env bash
# tmux-job: spin up `job-back` (8 panes) and `job-devops` (4 panes) sessions.
# Re-running is safe: existing sessions are left alone unless you pass --fresh.

set -euo pipefail

BACK_SESSION="job-back"
DEVOPS_SESSION="job-devops"
BACK_DIR="$HOME/job/mainflux"
DEVOPS_DIR="$HOME/job/devops/charts/mainflux"

FRESH=0
[[ "${1:-}" == "--fresh" ]] && FRESH=1

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not installed" >&2
  exit 1
fi

# Send a command into a pane without pressing Enter, so you can review before running.
queue() {
  local target="$1" cmd="$2"
  tmux send-keys -t "$target" "$cmd"
}

# Send and execute immediately (used for the read-only/safe commands).
run() {
  local target="$1" cmd="$2"
  tmux send-keys -t "$target" "$cmd" C-m
}

# Create a named window in a session (or rename the first window on session creation).
add_window() {
  local session="$1" name="$2" dir="$3"
  if tmux list-windows -t "$session" -F '#{window_name}' 2>/dev/null | grep -qx "$name"; then
    return
  fi
  tmux new-window -t "$session" -n "$name" -c "$dir"
}

build_back() {
  tmux new-session -d -s "$BACK_SESSION" -n nvim -c "$BACK_DIR"
  add_window "$BACK_SESSION" shell  "$BACK_DIR"
  add_window "$BACK_SESSION" curl "$BACK_DIR"
  add_window "$BACK_SESSION" make   "$BACK_DIR"
  add_window "$BACK_SESSION" claude "$BACK_DIR"
  add_window "$BACK_SESSION" lg     "$BACK_DIR"
  add_window "$BACK_SESSION" dash   "$BACK_DIR"
  add_window "$BACK_SESSION" spotify "$BACK_DIR"

  # Wait for shells in each new window to finish initializing before sending keys.
  sleep 1

  run   "$BACK_SESSION":nvim   "nvim ."
  run   "$BACK_SESSION":curl  "clear"
  run   "$BACK_SESSION":shell "clear"
  run   "$BACK_SESSION":make   "clear"
  run   "$BACK_SESSION":claude "cl"
  run   "$BACK_SESSION":lg     "lg"
  # gh dash is launched later, after a client attaches — see end of script.
  # Launching it now (while the session is detached) crashes its markdown renderer.
  run   "$BACK_SESSION":spotify "spotify_player"

  tmux select-window -t "$BACK_SESSION":nvim
}

build_devops() {
  # 4 windows: nvim, shell, claude, k9s
  tmux new-session -d -s "$DEVOPS_SESSION" -n nvim -c "$DEVOPS_DIR"
  add_window "$DEVOPS_SESSION" shell  "$DEVOPS_DIR"
  add_window "$DEVOPS_SESSION" claude "$DEVOPS_DIR"
  add_window "$DEVOPS_SESSION" k9s    "$DEVOPS_DIR"

  sleep 1

  run   "$DEVOPS_SESSION":nvim   "nvim values.yaml"
  run   "$DEVOPS_SESSION":shell  "clear"
  run   "$DEVOPS_SESSION":claude "cl"
  run   "$DEVOPS_SESSION":k9s    "clear"

  tmux select-window -t "$DEVOPS_SESSION":nvim
}

ensure_session() {
  local name="$1" builder="$2"
  if tmux has-session -t "$name" 2>/dev/null; then
    if [[ $FRESH -eq 1 ]]; then
      tmux kill-session -t "$name"
      "$builder"
    fi
  else
    "$builder"
  fi
}

ensure_session "$BACK_SESSION"   build_back   &
ensure_session "$DEVOPS_SESSION" build_devops &
wait

# Launch gh dash only once a client is attached to job-back; otherwise the TUI
# panics because it can't read a real terminal profile/size.
(
  while [ "$(tmux display-message -t "$BACK_SESSION" -p '#{session_attached}' 2>/dev/null)" = "0" ]; do
    sleep 0.1
  done
  sleep 0.3
  tmux send-keys -t "$BACK_SESSION":dash 'gh dash' Enter 2>/dev/null || true
) &
disown

if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$BACK_SESSION"
else
  tmux attach -t "$BACK_SESSION"
fi
