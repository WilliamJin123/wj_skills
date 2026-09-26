#!/usr/bin/env bash
# Live context for the tutor-init skill.
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
  local f
  echo "cwd: $PWD"
  echo
  echo "project metadata present:"
  for f in README.md CLAUDE.md AGENTS.md package.json pyproject.toml Cargo.toml go.mod pom.xml build.gradle Gemfile composer.json; do
    [ -f "$f" ] && echo "  $f"
  done
  echo
  if [ -f .tutor/config.yaml ]; then
    echo ".tutor/config.yaml: exists (reconfigure mode)"
  else
    echo ".tutor/config.yaml: missing (first-time setup)"
  fi
  echo "CLAUDE.md tutor:triggers block: $(grep -q 'tutor:triggers' CLAUDE.md 2>/dev/null && echo present || echo absent)"
  echo "tutorials in $(tutorial_dir)/: $(ls "$(tutorial_dir)"/*.md 2>/dev/null | wc -l | tr -d ' ')"
  if in_git; then
    echo
    echo "top file extensions (tracked files):"
    t git ls-files | sed -n 's/.*\.\([A-Za-z0-9]\{1,8\}\)$/\1/p' | sort | uniq -c | sort -rn | head -n 8
  fi
  if [ -f README.md ]; then
    echo
    echo "README.md (first 15 lines):"
    head -n 15 README.md
  fi
}

main 2>/dev/null | head -n 150
exit 0
