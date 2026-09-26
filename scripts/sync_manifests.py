"""
Generate Codex and Cursor manifests from the Claude Code ones.

Source of truth:
  .claude-plugin/marketplace.json      (plugin list)
  <plugin>/.claude-plugin/plugin.json  (name, version, description, ...)

Generated:
  .agents/plugins/marketplace.json     (Codex marketplace)
  .cursor-plugin/marketplace.json      (Cursor marketplace)
  <plugin>/.codex-plugin/plugin.json
  <plugin>/.cursor-plugin/plugin.json
  `version:` line in each <plugin>/skills/*/SKILL.md that has one

Usage:
  python scripts/sync_manifests.py          # write files, print what changed
  python scripts/sync_manifests.py --check  # exit 1 if anything is out of sync
"""

import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

# Codex marketplace UI fields that have no Claude Code equivalent.
CODEX_INTERFACE = {
    "adversary": {
        "displayName": "Adversary",
        "category": "Coding",
        "capabilities": ["Interactive", "Write"],
        "defaultPrompt": [
            "Critique the changes on this branch.",
            "Run a red-team sweep since the last audit.",
        ],
    },
    "humanizer": {
        "displayName": "Humanizer",
        "category": "Productivity",
        "capabilities": ["Interactive", "Write"],
        "defaultPrompt": ["Rewrite this text in my voice without changing its facts."],
    },
    "task-sprint": {
        "displayName": "Task Sprint",
        "category": "Productivity",
        "capabilities": ["Interactive", "Write"],
        "defaultPrompt": ["Create today's task file.", "Run the pending tasks in .task-sprint/."],
    },
    "tutor": {
        "displayName": "Tutor",
        "category": "Coding",
        "capabilities": ["Interactive", "Write"],
        "defaultPrompt": ["Set up tutorials for this project.", "Write a tutorial on the auth flow."],
    },
    "variations": {
        "displayName": "Variations",
        "category": "Productivity",
        "capabilities": ["Interactive"],
        "defaultPrompt": ["Give me 10 variations of this headline."],
    },
}


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def dump(data):
    return json.dumps(data, indent=2) + "\n"


def plugin_dirs():
    market = load(REPO_ROOT / ".claude-plugin/marketplace.json")
    for entry in market["plugins"]:
        yield entry, REPO_ROOT / entry["source"]


def desired_files():
    """Map each generated path to its expected text."""
    market = load(REPO_ROOT / ".claude-plugin/marketplace.json")
    out = {}
    codex_entries, cursor_entries = [], []

    for entry, pdir in plugin_dirs():
        claude = load(pdir / ".claude-plugin/plugin.json")
        name, version = claude["name"], claude["version"]
        ui = CODEX_INTERFACE.get(name, {"displayName": name, "category": "Productivity"})
        common = {
            "name": name,
            "version": version,
            "description": claude["description"],
            "author": claude["author"],
            "repository": claude.get("repository"),
            "license": claude.get("license"),
            "keywords": claude.get("keywords", []),
            "skills": "./skills/",
        }

        codex = dict(common)
        codex["interface"] = {
            "displayName": ui["displayName"],
            "shortDescription": entry["description"],
            "longDescription": claude["description"],
            "developerName": claude["author"]["name"],
            "category": ui["category"],
            "capabilities": ui.get("capabilities", ["Interactive"]),
            "defaultPrompt": ui.get("defaultPrompt", []),
        }
        out[pdir / ".codex-plugin/plugin.json"] = dump(codex)

        cursor = dict(common)
        cursor["displayName"] = ui["displayName"]
        out[pdir / ".cursor-plugin/plugin.json"] = dump(cursor)

        rel = "./" + pdir.relative_to(REPO_ROOT).as_posix()
        codex_entries.append({
            "name": name,
            "source": {"source": "local", "path": rel},
            "policy": {"installation": "AVAILABLE", "authentication": "ON_INSTALL"},
            "category": ui["category"],
        })
        cursor_entries.append({
            "name": name,
            "source": pdir.relative_to(REPO_ROOT).as_posix(),
            "description": entry["description"],
        })

        # Keep SKILL.md `version:` lines on the plugin version.
        for skill_md in sorted(pdir.glob("skills/*/SKILL.md")):
            text = skill_md.read_text(encoding="utf-8")
            head, sep, body = text.partition("\n---\n")
            new_head = re.sub(r"^version: .*$", f"version: {version}", head, flags=re.M)
            out[skill_md] = new_head + sep + body

    out[REPO_ROOT / ".agents/plugins/marketplace.json"] = dump({
        "name": market["name"],
        "interface": {"displayName": "WJ Skills"},
        "plugins": codex_entries,
    })
    out[REPO_ROOT / ".cursor-plugin/marketplace.json"] = dump({
        "name": market["name"],
        "owner": market["owner"],
        "metadata": {"description": market.get("description", "")},
        "plugins": cursor_entries,
    })
    return out


def main():
    check = "--check" in sys.argv
    stale = []
    for path, text in desired_files().items():
        current = path.read_text(encoding="utf-8") if path.exists() else None
        if current == text:
            continue
        stale.append(path.relative_to(REPO_ROOT).as_posix())
        if not check:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding="utf-8")
    for rel in stale:
        print(f"[sync] {'out of sync' if check else 'wrote'}: {rel}")
    return 1 if check and stale else 0


if __name__ == "__main__":
    sys.exit(main())
