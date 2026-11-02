# SwiftUI

## Stories

- A separate UI-test target and scheme (e.g. `Films`), never in the test gate.
- A base class: launch with seed args, print `FILM-MARK <beat> <epoch>` at each beat, `start` after launch and `end` in `tearDown`.
- Hold 1.2 s on the opening screen. Hold 1.5 to 2 s on the payoff.
- Type a word per `typeText` call. Each call costs about 0.8 s, so a key per call looks slow.
- `-parallel-testing-enabled NO`: a parallel run records a clone, not the booted device.

## Recording

1. `xcrun simctl status_bar <udid> override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4`.
2. A test plan on the film scheme keeps Xcode's screen recording: `"defaultOptions": {"preferredScreenCaptureFormat": "video", "systemAttachmentLifetime": "keepAlways"}`.
3. `build-for-testing` first, so the film holds only the run.
4. `test-without-building -resultBundlePath run.xcresult -only-testing:<target>/<class>/test<Story>`.
5. `xcrun xcresulttool export attachments --path run.xcresult --output-path att`. The `.mp4` entry's `timestamp` in `manifest.json` is its first frame, on the same clock as the marks.
6. ffmpeg: `fps=60,trim=start:end,setpts=PTS-STARTPTS`, h264 crf 18, `yuv420p`, `+faststart`. Sheet: `fps=48/len,scale=150:-1,tile=12x4`. Beat sheets: `fps=20,tile=8x4`, up to 1.6 s from each mark.

Never use `simctl io recordVideo` for films. It writes frames only on change and drops still stretches from its clock, so films run fast and marks drift.
Never write output beside the stories folder: macOS is case-insensitive, and the build bundles it.

William's apps: `appship <slug> film <Story>... [--canvas]` does all of this (config `film:` in `ship.yml`).

## Stageshow rules in SwiftUI

| Rule | SwiftUI |
|---|---|
| A resizing surface never stretches its text | Animate a shape's frame. Lay out each face at its final size. Crossfade the faces. `matchedGeometryEffect` on a text container reflows the text |
| Numbers roll | `.contentTransition(.numericText(value:))`, with the change inside `withAnimation` |
| An object keeps its identity | `.contentTransition(.symbolEffect(.replace))` for glyph swaps |
| A title or label changes by fading | `.id(value)` + `.transition(.opacity)`. A plain `navigationTitle` change swaps in one frame: use a `.principal` toolbar item |
| Nothing pops; a new row carries the rows below | List changes inside `withAnimation` (wrap the live-query setter) |
| A page swap keeps the chrome | `.id(state)` + `.transition(.opacity)` on the body only |
| Feedback is as quick as the product | `.snappy` for direct feedback; springs where a surface travels |
| No stale frame | A row shows the typed text until the store returns it, not the last saved value |

Pitfalls:

- A copy of a view drawn for motion can steal focus from the live one (two text fields bound to one focus state). Give the copy its own model, and mark it disabled and hidden from accessibility.
- Spring completion handlers run after the spring settles, not when it looks settled. Remove the moving copy only there.
- Opacity on a whole List also fades its separators and backgrounds. Fade the content, not the surface.
