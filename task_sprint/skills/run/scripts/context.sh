#!/usr/bin/env bash
# Live context for the task-sprint-run skill.
# Claude Code runs this when the skill loads (dynamic context injection);
# other agents (Codex, Cursor, ...) can run it by hand.
# Safeguards: read-only, no network, takes no user input, every git/find
# call time-limited, output capped, always exits 0. A non-zero exit would
# abort the skill load in Claude Code.

export GIT_OPTIONAL_LOCKS=0 GIT_TERMINAL_PROMPT=0 GIT_PAGER=cat PAGER=cat LC_ALL=C

# Run a command with a 5s limit when a timer is available.
t() {
  if command -v timeout >/dev/null 2>&1; then timeout 5 "$@"
  elif command -v perl >/dev/null 2>&1; then perl -e 'alarm 5; exec @ARGV or exit 127' "$@"
  else "$@"; fi
}

in_git() { t git rev-parse --is-inside-work-tree >/dev/null 2>&1; }

default_branch() {
  local b
  b=$(t git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) && { echo "${b#origin/}"; return; }
  for b in main master; do
    t git show-ref --verify --quiet "refs/heads/$b" && { echo "$b"; return; }
  done
}

# Pass input through, or print "(none)" when empty.
orn() { local o; o=$(cat); if [ -n "$o" ]; then printf '%s\n' "$o"; else echo "  (none)"; fi; }

main() {
  local today f
  today=$(date +%Y_%m_%d)
  echo "today: $today"
  if [ ! -d .task-sprint ]; then echo ".task-sprint/: missing"; return; fi
  echo
  echo "task files (pending / in-progress / done / failed), newest 15:"
  for f in $(ls .task-sprint/TASKS_*.md 2>/dev/null | sort | tail -n 15); do
    printf '%s  [ ]=%s [IP]=%s [x]=%s [!]=%s\n' "$f" \
      "$(grep -c '^- \[ \]' "$f")" "$(grep -c '^- \[IP\]' "$f")" \
      "$(grep -c '^- \[x\]' "$f")" "$(grep -c '^- \[!\]' "$f")"
  done
  if [ -f .task-sprint/CONTEXT.md ]; then
    echo
    echo "CONTEXT.md (first 80 lines):"
    head -n 80 .task-sprint/CONTEXT.md
  else
    echo
    echo "CONTEXT.md: missing"
  fi
}

main 2>/dev/null | head -n 150
exit 0
