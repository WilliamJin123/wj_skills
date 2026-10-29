#!/usr/bin/env bash
# Context for /handoff:resume [key]: the handoff, then each file under "Read first".
# Read-only; always exits 0.
want=$(printf '%s' "${1:-}" | tr -cd 'a-z0-9-')
list=$(ls -t */designs/handoffs/*.md */docs/handoffs/*.md designs/handoffs/*.md docs/handoffs/*.md handoffs/*.md 2>/dev/null)
[ -z "$list" ] && { echo "No handoff found under $PWD."; exit 0; }
if [ -n "$want" ]; then f=$(echo "$list" | grep -m1 -E "(^|/)$want\.md$")
else f=$(echo "$list" | head -1); fi
[ -z "$f" ] && { echo "No handoff named '$want'. Found:"; echo "$list"; exit 0; }
echo "Handoff: $PWD/$f"
[ -z "$want" ] && [ "$(echo "$list" | wc -l)" -gt 1 ] && { echo "Others (newest first):"; echo "$list" | tail -n +2 | sed 's/^/  /'; }
echo; cat "$f"; echo
base=$(cd "$(dirname "$f")/../.." && pwd)
# backticked paths in the Read first section; path:line keeps the path
python3 - "$f" "$base" <<'PY' 2>/dev/null
import os, re, sys
f, base = sys.argv[1], sys.argv[2]
text = open(f).read()
m = re.search(r"\*\*Read first\*\*(.*?)(?:\n\d+\.\s+\*\*|\n## |\Z)", text, re.S) or re.search(r"Read first(.*?)(?:\n## |\Z)", text, re.S)
if not m: sys.exit()
budget = 3000
for raw in re.findall(r"`([^`\s]+)`", m.group(1)):
    p = raw.split(":")[0]
    for cand in (p, os.path.join(base, p), os.path.join(os.getcwd(), p), os.path.expanduser(p)):
        if os.path.isfile(cand): break
    else:
        print(f"\n===== {raw}: not found."); continue
    lines = open(cand, errors="replace").read().splitlines()
    cap = min(len(lines), 600, budget)
    if cap <= 0:
        print(f"\n===== {raw}: not loaded, budget spent. Read it yourself."); continue
    print(f"\n===== {raw} ({len(lines)} lines{', first %d' % cap if cap < len(lines) else ''})")
    print("\n".join(lines[:cap]))
    budget -= cap
PY
exit 0
