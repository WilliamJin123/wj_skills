---
name: ui-design
description: The front door for any product UI change in any repo (a page, a part, a layout fix, a new screen, a restyle). Says which design rules win, in order, and runs the proof step every UI change needs before commit: shots at 390 and 1280 in light and dark, a box-fit check, and a fresh-eye review. Use it whenever you change how something looks or lays out, even when a repo has its own UI skill; that skill gives the how, this one gives the rules order and the proof. For a faux UI illustration with no product behind it, use stageshow; for motion, also stagefilm.
---

# UI design

A UI change is done when you have looked at it, at two widths, in both looks, and a reviewer who did not build it has looked too. Not when it compiles.

## 1. Rules, in order

The first source that speaks wins. Never copy a rule from a lower source over a higher one.

| # | Source | Where |
|---|---|---|
| 1 | The project's approved design artifact or mock | the repo's `CLAUDE.md` names it (wren: `designs/2026-10-20-design-language/`, judge `designs/2026-10-21-artifact-match.md`). Port its CSS values; never by eye |
| 2 | The project's design rules | `DESIGN.md` at the repo root; tokens in the code |
| 3 | Stageshow craft | `~/.claude/skills/stageshow/references/craft.md`: restraint, type, spacing and insets, icons, color. Read it in full: it is short |
| 4 | William's SOPs | skills `sop-ui-structure` (fewer lines and layers, one icon set), `sop-ux-laws` (placement and grouping), `sop-app-polish` (motion, art) |
| 5 | Platform feel | skill `apple-design` (gestures, springs, materials); skill `stagefilm` for any motion |

From stageshow, only craft, the review and the box check transfer to a real product. Skip framing, bleed, gray filler bars, the kit and "3 to 7 real strings": they are for illustrations.

If the repo has its own UI skill (wren: `wren-ui`), follow its loop for where parts and stories live and how to start them. Then do step 3 here as well.

## 2. Build

- Shared parts first. Change the part, not one page's copy of it.
- Every state: empty, loading, error, long text, many rows, narrow. A story or fixture per state where the repo has stories.
- Synthetic data only in public repos.

## 3. Prove it (every UI change, before commit)

1. Serve it locally. Prefer a story (Storybook) for a part. Use the dev server for a whole page or the shell. Never shoot prod.
2. Shoot every changed screen:
   ```
   node <this skill's folder>/scripts/shoot.mjs <url>... [--dark-param globals=theme:dark] [--select main]
   ```
   Run it from the project folder, so it finds the project's Playwright. It shoots each URL at 390 and 1280, light and dark. It runs stageshow's box-fit check on each shot and prints the PNG paths, the findings and any page or console error.
   - The looks come from `prefers-color-scheme`. An app that sets its own look ignores that: the script prints `same look` and exits 1. Then pass `--light-js`/`--dark-js` (a script run before the shot) or `--light-param`/`--dark-param` (a query added to the URL). The repo's UI skill names the right one.
   - A state that needs a click (an open menu, a hover tip): shoot it with your own Playwright lines, at the same widths.
3. Read every PNG. Open each with the Read tool. Name the largest fault and fix it, then shoot again. Order: layout and fit, then hierarchy, then spacing and type, then polish.
4. Box-fit findings: fix each one, or write in one line why it is a false alarm. Its lines and their meaning: the table "Lines that are never intentional" in `~/.claude/skills/stageshow/references/rehearse.md`. Never clear a line by hiding the thing it points at.
5. Worst case: run the `break-ui` skill on every changed part. When motion changed, also run `review-animations`. Fix what each finds, or write in one line why not.
6. Fresh-eye review. Give one subagent (Sonnet) the PNG paths, the rules sources above and the brief in `~/.claude/skills/stageshow/references/review.md`. Do not give it your view of the screens. Fix what it finds that the rules support. Push back on the rest, in one line each.
7. Check the diff against the artifact (rule 1). Then run the repo's UI gate.

## 4. Hand over

Tell William, in a few lines: the widths and looks you shot, the box-fit count (fixed, false alarms), what the review found, and what you did not check. Stop every server and browser you started.
