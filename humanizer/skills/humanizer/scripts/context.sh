#!/usr/bin/env bash
# Live context for the humanizer skill.
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
  local f
  echo "cwd: $PWD"
  [ "$PWD" = "$HOME" ] && { echo "(home directory: skipping file scan)"; return; }
  echo
  echo "possible voice or style samples (depth 3, first 15):"
  t find . -maxdepth 3 \( -name node_modules -o -name .git -o -name dist -o -name build -o -name .venv \) -prune -o -type f \( \
      -iname 'voice*.md' -o -iname 'STYLE*.md' -o -iname '*style*guide*' -o -iname '*writing*sample*' \
      -o -iname 'tone*.md' \) -print | head -n 15 | orn
  echo
  echo "writing-style sections in project agent files:"
  for f in CLAUDE.md AGENTS.md .cursorrules; do
    [ -f "$f" ] && grep -n -i -E '^#+ .*(writing|voice|style|tone)' "$f" | head -n 5 | sed "s|^|$f:|"
  done | orn
}

main 2>/dev/null | head -n 150
exit 0
