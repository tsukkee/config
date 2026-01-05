#!/bin/bash

target_pane="$1"
target_pane_width="$2"
target_pane_cwd="$3"

if [ -z "$target_pane" ]; then
  echo "Usage: $0 target-pane-id"
  exit 1
fi

tmpfile=$(mktemp -u).md

tmux display-popup -E -xP -yP -w$target_pane_width -h15 -d$target_pane_cwd "vim '$tmpfile'"
exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  content=$(cat "$tmpfile")
  tmux send-keys -t "$target_pane" "$content"
else
  tmux display-message "Editor exited with code $exit_code; skipping send-keys."
fi

rm -f "$tmpfile"
