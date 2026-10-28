# Two-layer system map: generated shape, written why

Read this after [system-map.md](system-map.md) when the subject repo has a generated map: a
`kestrel.json` at its root, or any tool that writes the code's shape (imports, exports, routes,
tables, systems, screens) into `map/generated/` from the code itself.

Then the map has two layers. The **generated layer** holds the shape: every node, edge and
signature, made from the code, so it cannot drift. A person approves it as a whole, and the
approval is a commit. The **written layer** is the cards. They hold only what code cannot say:
why this shape, the options beaten, what a change hits, when to switch.

Everything in system-map.md holds, except the changes below.

## What changes

| system-map.md says | Two-layer mode does |
|---|---|
| Card **Shape** lists keys and files, with citations | Shape is the generated page. The card names its nodes in `covers`, and `entity` gives its default coverage. Never copy a signature, a column or a route into a card |
| `status: verified` needs a date, a commit and citations | `stamp` replaces it. Run `kestrel stamp <card>` after you read the card against the approved map. A covered node that changes makes the card stale in `kestrel check` |
| Slice 0: list the tree, infer the nouns | Run `kestrel gen`, then `kestrel view`. The nouns are the generated roles (package, table, system, service). Inventory reads the map, not the tree |
| Slice 2: one card per type you find | One card per node of each required role (`cards.require` in kestrel.json). `kestrel check` lists each one with no card |
| **Hits / Does not hit** from reading code | Check each claim against the imports and routes layers (`usedBy`, seams). A hit with no edge in the map is a claim to re-verify |
| Slice 5: re-verify by hand | `kestrel check` lists stale cards. Read each one again, fix it, stamp it |
| Five card types | Same five; `pattern`, `requirement` and `decision` gain one rule each, below |

## Card types in this mode

- **object**, **process**: as in system-map.md, with no Shape copy.
- **pattern**: one design pattern (cursor pagination, a send verdict). `covers` lists every node
  that uses it, so the map shows where it applies.
- **requirement**: one ask in the owner's words, dated. `covers` lists the nodes that meet it.
- **decision**: one hard-to-change choice: why, the options beaten, when to switch. A switch
  point that a number can measure goes in frontmatter as `trigger: {metric, node?, over}`.
  `kestrel check` flags it when the number goes over. Write a trigger only when the owner gave
  the number. Never invent one.

## Frontmatter keys

Add these rows to `map/_meta/schema.md`:

| Key | Values |
|---|---|
| `covers` | generated node ids. A file brings its exports |
| `stamp` | written by `kestrel stamp` only, never by hand |
| `trigger` | decisions only: `{metric, node?, over}` |

## Walk test additions

1. Does `kestrel check` show no "no card" lines for a required role?
2. Does it show no stale cards?
3. Pick one card. Does it state a fact that the generated page already holds? Cut it and point
   at the page.
4. Pick one Hits line. Does an edge in the map back it?

## Failure modes

- Copying the shape into a card. It goes stale on the next commit, and no check sees it.
- Editing `map/generated/` by hand. Only the generator and `kestrel approve` write there.
- Stamping a card without reading it. The stamp says a person read it.
- Approving the map one part at a time. The owner approves the whole map, once per design step.
- A decision trigger with an invented number. It flags at random and teaches people to ignore it.
