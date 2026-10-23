#!/usr/bin/env bash
# Live context for the jira skill.
# Claude Code runs this when the skill loads (dynamic context injection);
# other agents (Codex, Cursor, ...) can run it by hand.
# Safeguards: read-only, no network, takes no user input, every call
# time-limited, output capped, always exits 0. A non-zero exit would
# abort the skill load in Claude Code.

export GIT_OPTIONAL_LOCKS=0 GIT_TERMINAL_PROMPT=0 GIT_PAGER=cat PAGER=cat LC_ALL=C

# Run a command with a 5s limit when a timer is available.
t() {
  if command -v timeout >/dev/null 2>&1; then timeout 5 "$@"
  elif command -v perl >/dev/null 2>&1; then perl -e 'alarm 5; exec @ARGV or exit 127' "$@"
  else "$@"; fi
}

# acli on PATH, else the usual install folders.
find_acli() {
  command -v acli 2>/dev/null && return
  for p in "${LOCALAPPDATA:-}/Programs/acli/acli.exe" "$HOME/.local/bin/acli" /usr/local/bin/acli /opt/homebrew/bin/acli; do
    [ -x "$p" ] && { echo "$p"; return; }
  done
}

main() {
  local a
  a=$(find_acli)
  if [ -z "$a" ]; then
    echo "acli: NOT FOUND (see Install in the skill)"
  else
    echo "acli: $a"
    t "$a" --version | head -n 1
  fi
  # Ticket keys in the branch name and recent commits, if any.
  if t git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "branch: $(t git branch --show-current)"
    echo "keys in branch + last 20 commits:"
    { t git branch --show-current; t git log -20 --format=%s; } | grep -oE '\b[A-Z][A-Z0-9]+-[0-9]+\b' | sort -u | head -n 20 | tr '\n' ' '
    echo
  fi
}

main 2>/dev/null | head -n 150
exit 0
