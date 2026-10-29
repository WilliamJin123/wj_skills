---
name: handoff
description: >
  Write a handoff file so the user can /clear instead of compacting, and the next session
  continues the work with /handoff:resume. Use when the user asks for a handoff, says they
  will clear, or the context is long and a fresh session would be cheaper than a compaction.
version: 0.5.0
user-invocable: true
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/context.sh *)
---

# Handoff

Write the least a new session needs to continue. Nothing else. Then tell the user the line to paste after `/clear`.

## Live context

!`bash ${CLAUDE_SKILL_DIR}/scripts/context.sh ${CLAUDE_SESSION_ID}`

## Where

`<repo>/designs/handoffs/<YYYY-MM-DD>-<session key>.md`, beside the design docs of the repo the work is in. The key is the session name (`/rename`), else the short session id. Other sessions share the checkout, so the key keeps files apart. A second handoff on the same day overwrites yours; a new day makes a new file. Work across repos: put it in the main one.

Keep every handoff: old ones help debug. Never commit one. The script adds `handoffs/` to each repo's `.git/info/exclude`.

## Before you write

Check the facts, do not recall them:
- The repo list above, plus `git log --oneline -5` in each repo you changed.
- Which background tasks, servers and watchers of yours run now.

## Budget

The next session reads the whole file and every **Read first** file before it acts. Every line costs tokens.
- At most 30 lines and 300 words. One line per bullet.
- Point, do not copy. A fact in a commit message, design doc or the code gets a path or hash, not a summary.
- A rule that holds past this task goes to memory or CLAUDE.md now, not here.
- Nothing left to do? Write no handoff. Tell the user to `/clear`, and give any open question in your reply.

## Sections

1. **Goal**: the task in one sentence, in the user's terms.
2. **Read first**: at most 3 entries, in order, each with why. A path in backticks, relative to the repo root or absolute. Give the part it needs as `path:start-end`. A whole file only when it is short or the next session edits most of it. `/handoff:resume` loads these, so check each path exists. This is the most important section.
3. **State**: commit hashes with pushed and deployed or not; uncommitted files; where the work stopped.
4. **Next**: the next steps, in order.
5. **Decisions**: each choice made with the user, one line with why. Name rejected options, so the next session does not offer them again.
6. **Rules**: user instructions for this task only, not in CLAUDE.md or memory. Exact words where the wording matters.
7. **Traps**: what failed and why, test quirks, what not to touch.
8. **Running**: processes to restart or stop (command, port, task name).
9. **Open questions**: what waits on the user.

Leave out empty sections.

## After you write

Reply with the path and this line:

`/clear`, then `/handoff:resume <session key>`
