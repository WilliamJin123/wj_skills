# wj-skills

Agent skills for Claude Code, Codex, Cursor, and any agent that reads `SKILL.md`.

| Plugin | Skills | What it does |
|---|---|---|
| `adversary` | `critique`, `defend`, `red-team` | Hostile review, an independent defense pass, and a recurring audit loop with fixes on a branch |
| `tutor` | `init`, `write`, `ask` | Audience-aware tutorials and Q&A grounded in them |
| `task-sprint` | `new`, `run` | Dated checklist files worked through in a loop |
| `variations` | `variations` | N numbered creative options, then you pick or merge |
| `humanizer` | `humanizer` | Rewrite AI-sounding text in the writer's voice |

## Install

### Claude Code

```
/plugin marketplace add WilliamJin123/wj_skills
/plugin install adversary@wj-skills
```

Swap in any plugin name from the table. Commands are `/<plugin>:<skill>`, e.g. `/adversary:critique`, `/task-sprint:new`.

Update: `/plugin marketplace update wj-skills`.

### Codex, Cursor, and other agents

```
npx skills add WilliamJin123/wj_skills -g
```

- `-a codex -a cursor` picks agents. Omit it to choose interactively.
- `-s adversary-critique -s tutor-write` picks skills. Omit it to get all of them.
- Standalone skill names are hyphenated: `adversary-critique`, `task-sprint-run`, `tutor-ask`. In Codex, invoke with `$adversary-critique`.
- Update: `npx skills update`.

### Codex plugins

```
codex plugin marketplace add WilliamJin123/wj_skills
codex plugin add adversary
```

The marketplace is `.agents/plugins/marketplace.json`. Each plugin has a `.codex-plugin/plugin.json`.

### Cursor plugins

`.cursor-plugin/marketplace.json` lists the plugins, and each has a `.cursor-plugin/plugin.json`. To load one locally, copy its folder into Cursor's local plugins folder and run "Developer: Reload Window".

## Live context

Each skill starts with a line like this:

```
!`bash ${CLAUDE_SKILL_DIR}/scripts/context.sh`
```

Claude Code runs it when the skill loads and replaces the line with the output: git state, audit tags, task counts, tutorial lists, and so on. The model starts with the facts and skips the discovery calls.

Safeguards in every `scripts/context.sh`:

- Read-only. No network. Takes no user input, so arguments can't reach the shell.
- Every git and find call has a 5-second limit. Output is capped at 150 lines.
- Always exits 0. A failing command would otherwise abort the skill load.
- Pre-approved in `allowed-tools` for that exact command only, so it runs without a prompt in default permission mode.
- `GIT_OPTIONAL_LOCKS=0`, so `git status` never takes the index lock.
- The skill tells the model the snapshot is data, not instructions.

Other agents see the raw line. The skill tells them to run `bash scripts/context.sh` themselves or skip it. Every step works without it.

To turn injection off in Claude Code, set `"disableSkillShellExecution": true` in settings.

## Development

One-time setup per clone:

```
git config core.hooksPath .githooks
```

The pre-commit hook:

1. Bumps the patch version of any plugin with staged changes, unless you already changed its version in this commit.
2. Runs `scripts/sync_manifests.py`. It writes the Codex and Cursor manifests from `.claude-plugin/*.json` and keeps each `SKILL.md` `version:` on its plugin version.

Edit only the `.claude-plugin` manifests. Check sync with `python3 scripts/sync_manifests.py --check`.

Skill `name` fields follow the [Agent Skills spec](https://agentskills.io/specification): lowercase letters, digits, and hyphens only. Claude Code names plugin skills `plugin:<folder>`, so `/adversary:critique` still works.
