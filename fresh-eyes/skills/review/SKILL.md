---
name: fresh-eyes-review
description: >
  Fresh-context review of a design doc or plan before its owner reads it. Three reviewers
  with no chat history (critic, reader, zoom-out) find what the author cannot see; the
  author checks each claim against the code, fixes the doc, logs what changed and lists
  what only the owner can decide. Use after writing a design doc with options, before
  showing it, or when asked to "fresh-eyes", "fresh-eye review" or "review this design".
  Not for code diffs (use /code-review) or small, obvious changes.
version: 0.1.0
user-invocable: true
---

# Fresh-eyes review

You wrote the doc and hold the whole chat. You cannot see what the doc leaves out, because you know it. Fresh reviewers read only the doc and the code. They find the gaps; you check them, fix the doc and hand it over.

Skip it for a doc under about 30 lines or a fix with one obvious shape: the review costs more than it finds.

## 1. Inputs

- **Doc**: the path. Its folder's repo is the working repo.
- **Reading list**: up to 10 files a new reader needs. Take every file path the doc names, plus the repo's entry file (`CLAUDE.md`, `map/routing.md` when there is one). A file outside the repo: copy it to the scratchpad and pass the copy.
- Pass nothing from the chat. No summary of the problem, no "the user wants". The doc must carry that itself; if it does not, that is a finding.

## 2. Round 1: critic and reader, in parallel

Spawn two subagents in one message (`Agent`, `subagent_type: general-purpose`). Each prompt is its brief from `references/reviewers.md`, verbatim, then the doc path and the reading list.

| Reviewer | Model | Finds |
|---|---|---|
| critic | opus | wrong claims about the code, gaps, risks, a missing option, missing Non-goals or Risks |
| reader | sonnet | what a new reader cannot follow: undefined terms, two meanings of one word, steps that assume knowledge |

They are read-only. They write nothing; each answers with its report.

## 3. Round 2: zoom-out

Spawn one more (opus) with its brief, the doc, the reading list and both reports. It adds its own simplicity findings and marks each round-1 finding keep, shrink (a smaller fix) or reject. Two reviewers who push opposite ways: it picks one.

## 4. Check, then fix the doc

Reviewers state wrong things with the same confidence as right ones (in the first trial, two said a workflow "exists nowhere"; it did). Before you act on a kept Blocker or Major:

- Open the `file:line` it cites. A claim about code with no citation is a question: answer it from the code.
- Drop what the code disproves. Note it as rejected, with the line that disproves it.

Then edit the doc yourself:

- Apply each fix you agree with. Fix the doc's words to the repo's writing rules as you go.
- A fix you reject: one line why, in the report.
- A choice the owner must make (scope, a reset, a cost, a rule): leave it out of the doc's recommendation and list it for the owner.
- Add one decision-log line: `YYYY-MM-DD: fresh-eyes review: N findings, M applied, K rejected; open: <the owner's decisions>.`

Keep the reports in the scratchpad (`fresh-eyes-<doc>-<date>/`), never in the repo.

## 5. Hand over

Tell the owner, short:

- The verdict in one line: ready, or what blocked it.
- What the review changed in the doc (the Blockers and Majors you applied).
- The decisions only they can make, each with your recommendation.
- The report's path.

## Rules

- A doc you did not write: read it, its decision log and the code it names first. You are its author now.
- One review per draft. Run it again only after a large rewrite.
- No review step edits the doc but you.
