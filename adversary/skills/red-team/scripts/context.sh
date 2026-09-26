#!/usr/bin/env bash
# Live context for the adversary-red-team skill.
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
  echo "today: $(date +%Y-%m-%d)"
  echo "cwd: $PWD"
  if ! in_git; then echo "git: not a repository"; return; fi
  local base branch dirty
  branch=$(t git branch --show-current)
  echo "branch: ${branch:-detached HEAD} (default: $(default_branch))"
  dirty=$(t git status --porcelain | wc -l | tr -d ' ')
  echo "working tree: $([ "$dirty" = 0 ] && echo clean || echo "$dirty uncommitted paths")"
  echo "remote: $(t git remote | head -n 1)"
  echo "fix branches: $(t git branch --list 'red-team/fixes-*' --format='%(refname:short)' | tr '\n' ' ')"
  base=$(t git tag -l 'audit/*' | sort | tail -n 1)
  echo "last audit tag: ${base:-none (full-repo scope)}"
  if [ -n "$base" ]; then
    echo
    echo "commits since $base ($(t git rev-list --count "$base..HEAD")), first 20:"
    t git log --oneline "$base..HEAD" | head -n 20
    echo
    echo "files changed since $base ($(t git diff --name-only "$base..HEAD" | wc -l | tr -d ' ')), first 60:"
    t git diff --name-only "$base..HEAD" | head -n 60
  fi
  echo
  echo "audit docs (newest 3):"
  ls designs/*-audit.md docs/audits/*-audit.md 2>/dev/null | sort | tail -n 3 | orn
  echo
  echo "decision logs:"
  ls -d designs/*spec*.md ADR* DECISIONS* docs/decisions 2>/dev/null | head -n 10 | orn
}

main 2>/dev/null | head -n 150
exit 0
