#!/usr/bin/env bash
# Context for /handoff:handoff: session key, dirty repos, default path.
# Read-only except .git/info/exclude; always exits 0 (non-zero aborts the skill load).
export GIT_OPTIONAL_LOCKS=0 GIT_PAGER=cat LC_ALL=C
sid="${1:-}"
# key = the /rename name, else first 8 of the session id
key=$(python3 - "$sid" <<'PY' 2>/dev/null
import glob, json, os, re, sys
sid = sys.argv[1]
for f in glob.glob(os.path.expanduser("~/.claude/sessions/*.json")):
    try: d = json.load(open(f))
    except Exception: continue
    if d.get("sessionId") == sid and d.get("nameSource") == "user" and d.get("name"):
        print(re.sub(r"[^a-z0-9]+", "-", d["name"].lower()).strip("-")); sys.exit()
print(re.sub(r"[^a-f0-9]", "", sid)[:8] or "session")
PY
)
echo "Session key: ${key:-session}"
# repos: cwd if git, else git dirs one level down
if git rev-parse --show-toplevel >/dev/null 2>&1; then repos=$(git rev-parse --show-toplevel)
else repos=$(for d in */.git; do [ -e "$d" ] && echo "$PWD/${d%/.git}"; done); fi
echo "Repos with uncommitted changes (yours or a peer's):"
for r in $repos; do
  s=$(git -C "$r" status --short 2>/dev/null | head -15)
  [ -n "$s" ] && { echo "- $r ($(git -C "$r" log --oneline -1 2>/dev/null))"; echo "$s" | sed 's/^/    /'; }
done
echo "Path: <repo>/designs/handoffs/${key:-session}.md (docs/handoffs if the repo has docs/ and no designs/; handoffs/ in the working folder when no repo fits)."
# keep handoffs out of git in every repo here, no commit needed
for r in $repos; do
  ex="$r/.git/info/exclude"
  [ -f "$ex" ] && ! grep -qx 'handoffs/' "$ex" && echo 'handoffs/' >> "$ex"
done
exit 0
