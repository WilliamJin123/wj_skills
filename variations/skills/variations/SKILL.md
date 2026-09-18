---
name: variations
description: >
  Produces N diverse numbered options (default 10) for taste-heavy work—copy,
  hooks, offers, funnels, ad angles, UI flows, palettes, headlines—then pauses
  for human pick/merge. Use when the user asks for variations, options, A/B
  directions, "10 versions," combine #1 with #3, or more like #2 and #7.
  Not for backend-heavy implementation unless they explicitly want creative alternatives.
version: 0.1.0
user-invocable: true
---

# Variations (HITL)

Generate **meaningfully different** numbered options, then **stop** for human direction. Do not pick a winner for the user unless they ask you to recommend after they have shortlisted.

## When to use

| Use | Skip |
|-----|------|
| Hooks, headlines, body copy, emails, ads | DB schema, API design, algorithms |
| Offer structure, pricing presentation, risk reversal, upsells, CTAs | Refactors, bugfixes, infra |
| Funnel steps, landing narrative, organic post angles | Unless user wants creative directions only |
| UI flow/layout concepts, section order, mobile-first page structure | Pixel-perfect polish of one locked design |
| Color/type **directions** (mood boards in words), not final tokens | Executing one chosen design in code (use other skills) |

Respect project context when present: `research.md`, `vision.md`, brand kit, ICP, constraints from Phase 0.

## Intake (before generating)

1. **Count** — Default `N = 10`. Override from user ("5 options", "generate 3 more").
2. **Artifact** — What are we varying? (one hook, full offer stack, hero section flow, etc.)
3. **Hard constraints** — Must keep / must avoid (legal, brand voice, price floor, channel).
4. **Axes to vary** — User may specify (e.g. risk reversal types, free lead-in vs paid-first, upsell placement). If silent, infer 3–5 orthogonal axes and state them in one short block before the variations.
5. **Prior set** — If continuing a session, treat earlier numbers as fixed context; new numbers continue the sequence or start a labeled "Round 2" set.

## Diversity rules (non-negotiable)

- **Orthogonal spread**: Variations should differ on *mechanism or structure*, not synonym swaps.
- **No clones**: If two options share the same angle and structure, replace one.
- **Cover the request**: When the user lists dimensions (e.g. guarantees, trials, downsells), ensure the set **explores** those dimensions across the batch—not necessarily one per variation, but none left unexplored unless N is too small (then say which dimensions were deferred).
- **Copy**: Vary hook archetype, proof type, objection handling, CTA friction, length, and tone—not just word choice.
- **UI / funnel**: Vary layout archetype, information order, social proof placement, and primary action—not only color adjectives.
- **Mobile-first** for funnel/UI: call out how each option reads on a narrow viewport (fold, thumb reach, scroll depth).

## Output format

Start with a compact **variation plan** (axes + N). Then emit exactly **N** items using this shape:

```markdown
## Variation plan
- **N**: 10
- **Axes**: …
- **Constraints**: …

---

### #1 — [short label]
**Axes emphasized**: …
**Summary**: 1–2 sentences.
**Full**: [the actual copy / structure / flow description]
**Mobile / funnel note** (if UI or landing): …

### #2 — …
…
```

End with a **HITL block** (always):

```markdown
---
**Your turn** — Reply with any of:
- Picks: e.g. "shortlist #2, #5, #9"
- Merge: e.g. "hook from #1 + risk reversal from #4 + CTA from #7"
- Expand: e.g. "5 more in the vein of #2 and #7, weirder hooks"
- Refine: e.g. "take #3 to 50% length, same angle"
- Constraints: tighten/loosen rules for the next round
```

Do **not** implement code, publish, or finalize a single option until the user converges (unless they say "pick one and implement").

## Convergence workflows

### Merge
Produce **one** merged candidate labeled **#M1** (or next id), with a bullet list of what came from which source numbers. Offer 2–3 micro-tweaks as sub-bullets only if useful—not a full new batch.

### "More like these"
Generate a **new batch** of size N′ (default 5 if unspecified). Parent variations must be named. Bias toward shared traits but still satisfy diversity rules (at least half should introduce a fresh axis).

### Refine one
Rewrite a single numbered item; keep the same label or use `#3b` if both versions should remain visible.

### Shortlist → final
After user shortlists, optionally produce a comparison table (strengths, risks, best channel) **without** declaring a winner unless asked.

## Batch size reference

| User says | Do |
|-----------|-----|
| (nothing) | N = 10 |
| "3 options" | N = 3 |
| "generate 5 more" | N = 5, new round, reference prior numbers |
| "explore only risk reversal" | N default, but every variation must change guarantee/trial/refund logic |

## Quality check (self, before sending)

- [ ] Exactly N variations, sequentially numbered
- [ ] Plan axes stated up front
- [ ] No two variations collapse to the same strategy
- [ ] HITL block present
- [ ] User-specified dimensions addressed or explicitly deferred

## After the user converges

Default is **chat-only**—no required project files. When they pick or merge a winner, give a short **chosen direction** recap (label, 3–5 bullets: what we kept, constraints, open questions). That recap is enough for the next message (“build this out,” implement landing, etc.) to pick up context.

Only write to disk if they explicitly ask (e.g. “save this to vision.md”). Never overwrite existing phase artifacts without confirmation.

Works standalone or inside a phased harness (e.g. offer exploration in Phase 2); critique/evaluator passes stay **separate** skills—do not auto-invoke them from here.
