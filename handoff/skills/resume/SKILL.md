---
name: resume
description: >
  Continue work from a handoff file that /handoff:handoff wrote. Loads the handoff and the
  files under its "Read first" section into context. Use after /clear when the user says
  resume, continue from the handoff, or names a handoff key.
version: 0.5.0
user-invocable: true
argument-hint: "[session key]"
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/load.sh *)
---

# Resume from a handoff

The handoff and its **Read first** files are below. You need not search for them.

!`bash ${CLAUDE_SKILL_DIR}/scripts/load.sh $ARGUMENTS`

## Then

1. If no handoff loaded, list the ones found and ask which. Stop.
2. Read any **Read first** file the loader cut or skipped.
3. Check the state the handoff gives: `git status` and `git log --oneline -3` in its repos. Note any change since the handoff.
4. Report to the user in a few lines: the goal, what changed since the handoff, what **Running** lists, and the first **Next** item you plan to do.
5. Stop and wait for the user. Do not restart **Running**, edit, claim or build until the user replies. They may change the plan.
6. When the user says go: restart **Running** if it still applies, then do **Next**. Follow **Rules** and **Decisions**: do not offer a rejected option again.
7. If you `/rename` this session to the same key, your next handoff today overwrites this file.
8. Never delete a handoff: old ones help debug. Resume takes the newest file for a key.
