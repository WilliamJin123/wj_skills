---
name: handoff
description: >
  Write a handoff file so the user can /clear instead of compacting, and the next session
  continues the work with /handoff:resume. Use when the user asks for a handoff, says they
  will clear, or the context is long and a fresh session would be cheaper than a compaction.
version: 0.2.0
user-invocable: true
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/context.sh *)
---

# Handoff

Write what a new session needs to continue. Nothing else. Then tell the user the line to paste after `/clear`.

## Live context

!`bash ${CLAUDE_SKILL_DIR}/scripts/context.sh ${CLAUDE_SESSION_ID}`

## Where

`<repo>/designs/handoffs/<session key>.md`, beside the design docs of the repo the work is in. The key is the session name (`/rename`), else the short session id. One file per session: other sessions share the checkout. Overwrite your own file on a second handoff. Work across repos: put it in the main one.

Never commit a handoff. The script adds `handoffs/` to each repo's `.git/info/exclude`.

## Before you write

Check the facts, do not recall them:
- The repo list above, plus `git log --oneline -5` in each repo you changed.
- Which background tasks, servers and watchers of yours run now.

## Sections

Short bullets. Summaries, not transcripts. Point to a file instead of copying it.

1. **Goal**: the task in one or two sentences, in the user's terms.
2. **Read first**: the files the next session must reread before it acts, in order, one per bullet, with why. Design docs, plans, specs, the code it will edit. Write each path in backticks, relative to the repo root or absolute (`path:line` is fine). `/handoff:resume` loads these files into the new session, so put no path here that it does not need. This is the most important section.
3. **Done**: what is finished, with commit hashes and whether it is pushed and deployed.
4. **In progress**: uncommitted changes (file list) and where the work stopped.
5. **Next**: the next steps, in order.
6. **Decisions**: each choice made with the user, and why. Include rejected options, so the next session does not offer them again.
7. **Rules from this session**: instructions the user gave that are not in CLAUDE.md or memory. Exact words where the wording matters.
8. **Traps**: what failed and why, test quirks, things not to touch.
9. **Running**: processes to restart or stop (command, port, task name).
10. **Open questions**: what waits on the user.

Leave out what CLAUDE.md, memory or the files already say. Leave out empty sections.

## After you write

Reply with the path and this line:

`/clear`, then `/handoff:resume <session key>`
