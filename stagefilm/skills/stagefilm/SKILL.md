---
name: stagefilm
description: Polish and prove UI motion in the real product, then film it for demos. Stageshow's rules (motion, choreography, craft, rehearse, verify) applied to the app itself instead of a mock copy. Use when asked to animate screens, polish transitions, match a demo video, make product demo videos or promos of an app, or review motion; for SwiftUI apps on the iOS simulator and React apps through Storybook. Use stageshow itself only for a pure illustration with no product behind it.
---

# Stagefilm

**The product is the only source.** A mock of the UI drifts from the app within a day. So the motion is designed and checked in the app, and every demo video is a film of the app.

Stageshow (`benjitaylor/skills`, skill `stageshow`) holds the rules. Stagefilm does not copy them. It routes to them and replaces stageshow's mock kit and DOM filming with the product's own framework and a recorder.

## Read first

From the installed stageshow skill (`~/.claude/skills/stageshow/references/`, or wherever `npx skills` put it):

| Read | For |
|---|---|
| `motion.md` | story, beats, pace, text that changes, things that appear and leave, drags. Read in full before a spec |
| `choreography.md` | timing jobs and curves for one change |
| `craft.md` | restraint, type, spacing: the still frame each beat lands on |
| `rehearse.md`, `verify.md` | how to read a film; faults in order: framing, hierarchy, motion, polish |
| `teaching.md` | the side-by-side questions for the last pass |

Skip `kit.md`, `framing.md`, `looks.md`, `bento.md`, unless you make a marketing frame around a film.

## The loop

1. **Spec.** For each screen write in the design doc: the main action, 3 to 5 beats, the rule each beat obeys, the curve, and the poster frame (the still that tells the story alone).
2. **Build** in the product's framework. Platform notes: `references/swiftui.md`, `references/web.md`.
3. **Story.** A scripted test plays the spec at human pace and prints a mark at each beat. Seed data, never live data.
4. **Film.** Record the story, then cut an mp4, a contact sheet for the whole film, and a frame sheet for each beat at about 20 fps.
5. **Read.** Read the sheet, then each beat sheet frame by frame: press, morph, arrival, exit, the frame after it lands. Fix the largest fault. Film again. A still can't show a pop.
6. **Review.** Put the sheet where the owner reviews (a canvas, a PR). Send the mp4.
7. **Ship.** Run the tests once, then ship. Promo videos come from the same films, framed if needed.

Faults to look for every time:

- A flash of old content (a stale value for one frame after an edit).
- Text that reflows or stretches while its surface resizes.
- Content that swaps in one frame instead of moving or fading.
- A blank frame between two states.
- A number that jumps instead of rolling.
- A beat that ends before its result is on screen, or a payoff tidied away.

## Platforms

- **SwiftUI (iOS):** `references/swiftui.md`. XCUITest stories in their own scheme, `simctl io recordVideo`, ffmpeg.
- **React (web):** `references/web.md`. Storybook stories of the real components, Playwright `recordVideo` on the story URL. Stageshow's kit may frame a story (Stage, Phone, cursor), but the components inside are the product's own.
