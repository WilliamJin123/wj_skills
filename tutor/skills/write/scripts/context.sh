#!/usr/bin/env bash
# Live context for the tutor-write skill.
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

# Tutorial dir from .tutor/config.yaml (output.directory); relative paths only.
tutorial_dir() {
  local d
  d=$(sed -n 's/^[[:space:]]*directory:[[:space:]]*//p' .tutor/config.yaml 2>/dev/null | head -n 1 | sed 's/[[:space:]]*#.*//; s/["'"'"']//g')
  case $d in ''|/*|*..*) d=tutorials/ ;; esac
  echo "${d%/}"
}

main() {
  local dir max n f
  if [ ! -f .tutor/config.yaml ] || [ ! -f .tutor/GUIDE.md ]; then
    echo "tutor config: missing (.tutor/config.yaml or .tutor/GUIDE.md)"
    return
  fi
  dir=$(tutorial_dir)
  echo ".tutor/config.yaml:"
  head -n 80 .tutor/config.yaml
  echo
  echo ".tutor/GUIDE.md: $(wc -l < .tutor/GUIDE.md | tr -d ' ') lines (read it in full before writing)"
  echo
  echo "existing tutorials in $dir/ (first 60):"
  ls "$dir"/*.md 2>/dev/null | head -n 60 | orn
  max=0
  for f in "$dir"/*.md; do
    [ -e "$f" ] || continue
    n=$(basename "$f" | sed -n 's/^\([0-9][0-9]*\).*/\1/p')
    [ -n "$n" ] && [ "$((10#$n))" -gt "$max" ] && max=$((10#$n))
  done
  printf 'next number prefix: %02d\n' "$((max + 1))"
  if in_git; then
    echo
    echo "branch: $(t git branch --show-current)"
    echo "recent commits:"
    t git log --oneline -8
    echo
    echo "recently changed files (last 5 commits):"
    t git diff --name-only HEAD~5..HEAD 2>/dev/null | head -n 20 | orn
  fi
}

main 2>/dev/null | head -n 150
exit 0
