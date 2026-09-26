#!/usr/bin/env bash
# Live context for the adversary-critique skill.
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
  echo "cwd: $PWD"
  if ! in_git; then echo "git: not a repository"; return; fi
  local branch base
  branch=$(t git branch --show-current)
  base=$(default_branch)
  echo "branch: ${branch:-detached HEAD} (default: ${base:-unknown})"
  echo
  echo "uncommitted changes (status, first 30):"
  t git status --short | head -n 30 | orn
  echo
  echo "uncommitted diff stat vs HEAD:"
  t git diff HEAD --stat | tail -n 25 | orn
  if [ -n "$base" ] && [ -n "$branch" ] && [ "$branch" != "$base" ]; then
    echo
    echo "branch diff stat ($base...HEAD):"
    t git diff --stat "$base...HEAD" | tail -n 25 | orn
  fi
  echo
  echo "recent commits:"
  t git log --oneline -8
  echo
  echo "plan docs at root:"
  ls -d PLAN*.md ROADMAP.md PROJECT.md .planning 2>/dev/null | head -n 10 | orn
}

main 2>/dev/null | head -n 150
exit 0
