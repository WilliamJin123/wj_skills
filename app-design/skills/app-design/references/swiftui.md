# SwiftUI map

The laws in SKILL.md are platform-neutral. This file gives the SwiftUI form of each Expo rule. Where SwiftUI has no equivalent, the row says so.

## Stack

| Expo rule | SwiftUI |
|---|---|
| Expo Router | `NavigationStack` with a typed path; `TabView` for tabs |
| Reanimated, gesture handler | `withAnimation`, `.animation(_:value:)`, `DragGesture`, `MagnifyGesture`. Already on the render thread: no worklet rule |
| FlashList | `List`, or `LazyVStack` in a `ScrollView`; stable `id`s |
| TanStack Query, Zustand | `@Observable` models; a DB observation (GRDB `ValueObservation`) for stored data |
| MMKV, AsyncStorage | `@AppStorage` for tiny prefs; the DB for everything else |
| expo-image | `Image`, `AsyncImage`; asset catalog @2x/@3x |

## Native fidelity laws

| Law | SwiftUI |
|---|---|
| 1 Semantic colors | `.primary`, `.secondary`, `Color(.systemBackground)`, `Color(.secondarySystemBackground)`, or asset colors with a dark variant. Check `.preferredColorScheme(.dark)` and `xcrun simctl ui booted appearance dark` |
| 2 Native controls | `Toggle`, `Picker(.segmented)`, `DatePicker`, `.contextMenu`, `Menu`, `.confirmationDialog`, `.swipeActions`. Never draw a fake system control or fake glass |
| 3 SF Symbols | `Image(systemName:)`; `.symbolEffect`, `.contentTransition(.symbolEffect(.replace))`; one `.symbolRenderingMode` per app |
| 4 Type ramp | `.largeTitle` … `.caption2`; Dynamic Type is free unless you fix a size. `.monospacedDigit()` for counts and clocks. `.textSelection(.enabled)` on data |
| 5 Continuous corners | `RoundedRectangle(cornerRadius: r, style: .continuous)`, `.rect(cornerRadius:)` (continuous by default); iOS 26 `ConcentricRectangle` inside containers |
| 6 Shadows | `.shadow`: one elevation system |
| 7 Spacing rhythm | `spacing:` on stacks, `.padding(n)` from one scale; `.contentMargins` on scroll views |
| 8 Safe areas | `.safeAreaInset(edge:)` for bars; `.ignoresSafeArea` for backgrounds only |
| 9 Nav titles | `.navigationTitle`, `.toolbar`, `.navigationBarTitleDisplayMode` |
| 10 Haptics | `.sensoryFeedback(.selection / .success / .impact, trigger:)` |
| 11 Numbers | `.formatted()`, `.number.notation(.compactName)`, `Date.FormatStyle` |
| 12 Root scroll | `ScrollView`/`List` at the root of any screen that can overflow; `GeometryReader` only when layout needs it |

## Navigation laws

| Law | SwiftUI |
|---|---|
| Push vs replace | append to the path vs reset it (`path = [x]`) |
| Modal with steps | `.sheet` holding its own `NavigationStack`, Cancel / Done in its toolbar |
| Short interruption | `.sheet` + `.presentationDetents([.medium, .large])` |
| Immersive | `.fullScreenCover` with an explicit Close |
| Destructive confirm | `.confirmationDialog` |
| Block back | `.interactiveDismissDisabled(dirty)` on sheets; `.navigationBarBackButtonHidden` only for in-flight requests |

## Motion laws

| Law | SwiftUI |
|---|---|
| Settle spring `{400, 1}` | `.spring(duration: 0.4, bounce: 0)` (= `.smooth`) |
| Sheet spring `{300, 0.8}` | `.spring(duration: 0.3, bounce: 0.2)` (≈ `.snappy`) |
| Velocity into the spring | `DragGesture` `value.velocity`; `.interpolatingSpring(..., initialVelocity:)` or a `withAnimation(.spring)` the gesture state hands off to |
| Ease-out timing | `.timingCurve(0.23, 1, 0.32, 1, duration: 0.25)` |
| Enter from 0.95 + fade | `.transition(.scale(0.95).combined(with: .opacity))` |
| Press feedback | a `ButtonStyle` reading `configuration.isPressed`: scale 0.97 on cards, highlight on rows |
| Reduce Motion | `@Environment(\.accessibilityReduceMotion)` → swap spatial transitions for `.opacity` |
| Measure | Instruments, SwiftUI + Animation Hitches templates, release build |

## Simulator loop

| Step | Command |
|---|---|
| Run a flow | XCUITest with seeded launch arguments |
| Record | `xcrun simctl io <id> recordVideo f.mp4`, or Xcode's test recording; frames with `ffmpeg -vf fps=…` |
| Dark mode | `xcrun simctl ui <id> appearance dark` |
| Dynamic Type XL | `xcrun simctl ui <id> content_size extra-extra-extra-large` (then `accessibility-extra-large` for the AX check) |
| Small screen | an iPhone SE simulator: no island, 375 pt wide |
| Lock screen, island | screenshots skip the cover sheet: record video instead |
