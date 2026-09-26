#!/usr/bin/env bash
# Live context for the task-sprint-new skill.
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
  local today max n f
  today=$(date +%Y_%m_%d)
  echo "today: $today"
  if [ ! -d .task-sprint ]; then
    echo ".task-sprint/: missing (create it)"
    echo "next file: .task-sprint/TASKS_${today}_0.md"
    echo "CONTEXT.md: missing"
    return
  fi
  max=-1
  for f in .task-sprint/TASKS_"$today"_*.md; do
    [ -e "$f" ] || continue
    n=${f##*_}; n=${n%.md}
    case $n in ''|*[!0-9]*) continue ;; esac
    [ "$n" -gt "$max" ] && max=$n
    echo "exists: $f"
  done
  echo "next file: .task-sprint/TASKS_${today}_$((max + 1)).md"
  echo "CONTEXT.md: $([ -f .task-sprint/CONTEXT.md ] && echo exists || echo missing)"
}

main 2>/dev/null | head -n 150
exit 0
