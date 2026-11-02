# Web (React)

## Stories

- A Storybook story per screen state, built from the product's real components and fixture data.
- A `play` function drives the beats: `userEvent` clicks and typing at human pace (`delay: 70` per key), with a `FILM-MARK` console line at each beat.
- Stageshow's `Stage`, `Phone` or cursor may wrap the story for a marketing frame. The components inside stay the product's own; never redraw them.

## Recording

1. Open `iframe.html?id=<story>&viewMode=story` in Playwright with `recordVideo: { size }` at 2× the viewport. Playwright records at the viewport size and ignores `deviceScaleFactor`, so double the viewport and scale the root.
2. Collect the console `FILM-MARK` lines with their page times.
3. Wait for the `play` function to finish, then close the context. That writes the video.
4. Cut the mp4, the sheet and the beat sheets with ffmpeg, as for SwiftUI.

When a story is wrapped in stageshow's `Stage`, stageshow's `scripts/film.mjs <story url> --gate` also runs its DOM checks (clips, jumps, near-empty frames). It finds only `.ss-stage` elements, so a bare story gets frame reading alone.
