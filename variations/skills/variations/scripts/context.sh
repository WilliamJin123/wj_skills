#!/usr/bin/env bash
# Live context for the variations skill.
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
  [ "$PWD" = "$HOME" ] && { echo "(home directory: skipping file scan)"; return; }
  echo
  echo "project context files (depth 3, first 20):"
  t find . -maxdepth 3 \( -name node_modules -o -name .git -o -name dist -o -name build -o -name .venv \) -prune -o -type f \( \
      -iname 'research*.md' -o -iname 'vision*.md' -o -iname '*brand*.md' -o -iname 'icp*.md' \
      -o -iname 'DESIGN.md' -o -iname 'PRODUCT.md' -o -iname 'offer*.md' -o -iname 'positioning*.md' \
      -o -iname 'voice*.md' -o -iname '*style*guide*' -o -iname 'persona*.md' \) -print | head -n 20 | orn
}

main 2>/dev/null | head -n 150
exit 0
