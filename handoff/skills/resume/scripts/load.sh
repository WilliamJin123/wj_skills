#!/usr/bin/env bash
# Context for /handoff:resume [key]: the handoff, then each file under "Read first".
# Read-only; always exits 0.
want=$(printf '%s' "${1:-}" | tr -cd 'a-z0-9-')
list=$(ls -t */designs/handoffs/*.md */docs/handoffs/*.md designs/handoffs/*.md docs/handoffs/*.md handoffs/*.md 2>/dev/null)
[ -z "$list" ] && { echo "No handoff found under $PWD."; exit 0; }
if [ -n "$want" ]; then f=$(echo "$list" | grep -m1 -E "(^|/)([0-9]{4}-[0-9]{2}-[0-9]{2}-)?$want\.md$")
else f=$(echo "$list" | head -1); fi
[ -z "$f" ] && { echo "No handoff named '$want'. Found:"; echo "$list"; exit 0; }
echo "Handoff: $PWD/$f"
[ -z "$want" ] && [ "$(echo "$list" | wc -l)" -gt 1 ] && { echo "Others (newest first):"; echo "$list" | tail -n +2 | sed 's/^/  /'; }
echo; cat "$f"; echo
base=$(cd "$(dirname "$f")/../.." && pwd)
# backticked paths in the Read first section: path, path:N (N to N+80), path:A-B
python3 - "$f" "$base" <<'PY' 2>/dev/null
import os, re, subprocess, sys
f, base = sys.argv[1], sys.argv[2]
text = open(f).read()
m = re.search(r"\*\*Read first\*\*(.*?)(?:\n\d+\.\s+\*\*|\n## |\Z)", text, re.S) or re.search(r"Read first(.*?)(?:\n## |\Z)", text, re.S)
if not m: sys.exit()
budget, per_file = 900, 300
def find(p):
    for cand in (p, os.path.join(base, p), os.path.join(os.getcwd(), p), os.path.expanduser(p)):
        if os.path.isfile(cand): return cand
    # moved or misnamed: unique tracked file with the same tail
    try: tracked = subprocess.run(["git", "-C", base, "ls-files"], capture_output=True, text=True).stdout.split()
    except Exception: return None
    want = p.strip("/").split("/")
    def score(t):
        parts, n = t.split("/"), 0
        while n < min(len(parts), len(want)) - 1 and parts[n] == want[n]: n += 1
        return n
    hits = sorted((score(t), t) for t in tracked if t.split("/")[-1] == want[-1])
    if not hits or (len(hits) > 1 and hits[-1][0] == hits[-2][0]): return None
    return os.path.join(base, hits[-1][1])
seen = set()
for raw in re.findall(r"`([^`\s]+)`", m.group(1)):
    pm = re.fullmatch(r"([^:]+?)(?::(\d+)(?:-(\d+))?)?", raw)
    if not pm or ("/" not in pm.group(1) and "." not in pm.group(1)) or pm.group(1).endswith(")"): continue
    path = find(pm.group(1))
    if not path:
        print(f"\n===== {raw}: not found."); continue
    lines = open(path, errors="replace").read().splitlines()
    a = int(pm.group(2)) if pm.group(2) else 1
    b = int(pm.group(3)) if pm.group(3) else (a + 80 if pm.group(2) else len(lines))
    a, b = max(a, 1), min(b, len(lines))
    if (path, a, b) in seen: continue
    seen.add((path, a, b))
    cap = min(b - a + 1, per_file, budget)
    if cap <= 0:
        print(f"\n===== {raw}: not loaded, budget spent. Read it yourself."); continue
    moved = "" if os.path.normpath(path).endswith(os.path.normpath(pm.group(1))) else f", at {os.path.relpath(path, base)}"
    cut = f", cut at {a + cap - 1}" if a + cap - 1 < b else ""
    print(f"\n===== {raw} ({len(lines)} lines, {a}-{b}{moved}{cut})")
    print("\n".join(lines[a - 1:a - 1 + cap]))
    budget -= cap
PY
exit 0
