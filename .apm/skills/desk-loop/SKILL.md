---
name: desk-loop
description: Run a shared thinking workspace that takes a theme or a rough consultation ("何を作るべきか考えたい", "要件定義を作りたい", "設計書を書きたい", "この件を整理してレポートにしたい") through research, deliberation, and review to a third-party-readable deliverable document (plan, requirements, spec, design doc, strategy, report), while keeping a dense meta.md that explains why the deliverable starts where it starts, what was researched, how each conclusion was derived, and what still needs the user's judgment. Use for any desk work whose output is a document and whose reasoning the user wants to inspect at the thought-process level. Do not use for implementation, experiments, or code changes (hand the finished deliverable to an implementation workflow); do not use for quick questions that need no durable record.
argument-hint: A theme, a rough consultation, or the deliverable you want to think through.
---

# Desk Loop

The boundary of this skill is desk work versus execution. Everything that is researched, reasoned, and written down — requirements, specifications, design documents, plans, strategies, reports — is in scope, from the first vague consultation to a review-ready deliverable. Running code, experiments, or delivery work is out of scope and is handed off with the deliverable.

The user and the agent share time and a workspace, so they also share the meta level: not only the deliverable and the minimum logic that supports its conclusions, but why that starting point, why those evaluation criteria, what was investigated, and how each conclusion was derived. Misalignment is caught at the level of the thought process, not after the fact in the artifact. This is the reason `meta.md` exists and is kept as precise as the deliverable itself.

## Workspace

One directory per theme, `desk/<theme>/` unless the user specifies another location. Reuse an existing directory for the same theme rather than creating a parallel one. Write everything in the user's language.

| File | Role | Rewritten? |
|---|---|---|
| deliverable file(s) at the top level, named for what they are (e.g. `requirements.md`, `design.md`, `report.md`) | The output a third party reads. Clean, purpose-driven, no process residue. May not exist in the first cycle and may be mostly TBD when it first appears | Yes, freely, until final |
| `meta.md` | Why this deliverable, why this starting point and these criteria, what was researched, how each section's conclusion was derived, which alternatives were rejected and why, and the open items that need the user. Structure below | Yes, freely; always describes the current state |
| `record.md` | Append-only ledger of inputs as they entered: user statements, requirements, constraints, corrections, evidence intake. Read on its own to see what came in and when; nothing else in the workspace points into it | Never; corrections are new entries that cite what they supersede |
| `sub/*.md` | Primary research reports (what was read or observed, with source path or link, access date, and limitations) and detailed analyses cited from `meta.md` (option comparisons, exhaustive triage, derivations too long for `meta.md`). These, and primary sources themselves, are what `meta.md` cites | Research reports: no, append a new report instead. Analyses: yes |

`meta.md` is the entry point. Its head names the deliverable file(s) and the current status, so a third party who lands in the directory knows where to go.

## meta.md structure

A head of two to four lines, then exactly three top-level parts. Blocks inside Part 2 are headed to mirror the deliverable's top-level sections, so a change in the deliverable maps to exactly one block to rewrite.

- **Head.** Status (`exploring` = no deliverable yet, starting point under review; `drafting`; `review-ready`; `final`), links to the deliverable file(s) or "none (consultation outcome)", link to `record.md`.
- **Part 1 — Starting point.** Written in the first cycle and reviewed before drafting; changes rarely, and any change triggers re-examination of Part 2.
  - Problem as understood, in the agent's words, naming what introduced it (the user's request, a project document by path).
  - Deliverable, reader, scope. In consultation mode: the candidates considered and why one (or none) was chosen.
  - Evaluation criteria, each with one sentence on why that lens matters for this theme.
  - Research plan and results, linking the `sub/` reports and primary sources; what was deliberately not investigated and why.
  - Premises and provisional assumptions, each marked as user-given (with the gist of what the user said, quoted when wording matters) or agent-derived (with its source). Each provisional one is also a `Q-###`.
- **Part 2 — Reasoning, mirrored to the deliverable.** One block per deliverable section, same heading text, in prose: what the section concludes and which premises, evidence, and criteria it rests on, naming user-given premises by content and evidence by primary source or `sub/` report; the chain from those to the result (long or tabular derivations go to `sub/` and are linked, leaving only the connecting reasoning); which alternatives were considered and why each was rejected against the criteria, written as a comparison that stands on its own; what remains TBD and which `Q-###` or research item tracks it.
  - When the outcome is that no deliverable is warranted, Part 2 has no sections to mirror; it then holds the conclusion itself, its derivation from the inputs and criteria, the alternatives rejected, and the risks the user should keep in view, since there is no deliverable to carry them.
- **Part 3 — Dialogue items.** A table of open `Q-###`: question framed so the user can answer without re-reading the deliverable; why it is the user's (preference, scope, organizational fact) rather than researchable; the agent's recommendation and its cost; which deliverable section or Part 1 item it blocks. Provisional assumptions adopted to keep drafting are listed here marked as such. Resolved items are removed, not struck through.

Not in `meta.md`: history of how a conclusion changed (`record.md`), raw findings and long comparisons (`sub/`), risks the deliverable should state itself (deliverable), resolved questions (removed; the decision lives in Part 2 as reasoning).

## Sources and IDs

Citations in `meta.md` and `sub/` point at primary sources (a file path, a repository path with commit, a URL, a named document) or at a `sub/` report or analysis that captured them. They never point into `record.md`. Where the source is something the user said, write the content ("the user ruled out CI; tests run on the development instance"), quoting briefly when the wording matters.

- `record.md` entries carry a date, a source (who or what, and through which channel), the original wording or a labelled summary, and an entry number used only inside `record.md` so a later correction can name what it supersedes. When a dialogue item is answered, the entry restates the gist of the question alongside the answer so the ledger reads on its own.
- `Q-###` is the only ID that crosses a file boundary, and only between `meta.md` Part 3 and the review conversation. It names an open dialogue item so the user can answer it by number; it disappears from Part 3 when resolved and is not used to refer to the decision afterwards.
- The deliverable carries no process IDs. If its genre calls for its own IDs (requirement IDs, risk IDs), those belong to the deliverable.
- Decisions, hypotheses, evidence, and rejected alternatives do not get ledgers or IDs; they are written as reasoning in `meta.md` with their sources named.

## Entry modes

- **Theme only, consultation.** The user brings a subject and a vague intent ("this area worries me", "should we prepare something before X"). The first cycle's job is to decide, together, whether a deliverable is warranted, what kind, for whom, and at what scope. That decision is the first thing written into `meta.md` Part 1 and the first thing reviewed. "No deliverable needed; the meta-level clarification is the outcome" is a legitimate result and is recorded as such.
- **Deliverable known.** The user names what they want. Part 1 is shorter but still written and reviewed before drafting, because the wrong starting point is the most expensive error in desk work.

Both modes converge on the same loop.

## Loop

1. **Orient and capture.** Read the theme, the project materials the user points to, and what already exists in the workspace. Append new inputs to `record.md`. Research externally verifiable facts yourself; write a `sub/` report for anything more than a line, with source, access date, and limitations, and log the intake in `record.md`. Ask the user only for preferences, decisions, tacit context, and private organizational facts.
2. **Write the starting point.** Fill `meta.md` Part 1, put the questions that block it into Part 3 with your recommendation, and set status `exploring`. **Stop and review the starting point with the user before drafting**, opening `meta.md` in Crit as described under Review.
3. **Research and analyze.** Fill `sub/` with research reports and analyses. Keep breadth in `sub/`; keep the chain of reasoning in `meta.md`.
4. **Draft or rebuild the deliverable and `meta.md` together.** Set status `drafting` when the first deliverable file is created, and return to it from `review-ready` if a review reopens a blocking question. The deliverable may start as a skeleton with TBD slots. Every section of the deliverable has a corresponding Part 2 block; when one changes, rewrite the other in the same pass. Alternatives may coexist in the deliverable while undecided; mark them as such.
5. **Resolve through dialogue.** Present a small, coherent batch of `Q-###` items with a recommendation and its cost, so the user reacts to something concrete; open `meta.md` (and the deliverable, if it exists) in Crit so the user can answer on the items themselves. Wait for answers before advancing dependent items. Append each answer to `record.md` with the gist of the question it answers, so the ledger reads on its own. Then remove the resolved `Q-###` and write the decision into Part 2 as reasoning, naming the user's answer by content rather than by ledger entry.
6. **Review.** Every pause for the user — the starting-point review, each dialogue batch, each draft review — goes through Crit by default: open the files under review (`meta.md` alone while exploring; the deliverable and `meta.md` together once it exists) and wait for the user's comments there. Fall back to review in conversation only when Crit is unavailable, and say so. Treat each comment as a trigger to recompute the affected reasoning and its downstream conclusions across both files, not as a local text substitution.
7. **Offer finalization.** When no `Q-###` blocks the deliverable's purpose, set status `review-ready` and state residual uncertainty. Only the user declares `final`. On final, recheck consistency between deliverable and `meta.md`, working links, absence of process IDs and residue in the deliverable, and name the recommended next workflow (implementation, another desk-loop theme, or nothing).

Pause for the user after the starting-point review, after each dialogue batch, and after each review round, each time through Crit. Never invent the user's choices to keep the loop moving.

## Invariants

- **History versus rejected alternatives.** "The count was three, then reduced to two" is history; it lives in `record.md` and nowhere else. "A third option was considered and rejected because only one axis separates the cases" is part of the current judgment; it lives in `meta.md` Part 2. Neither the deliverable nor `meta.md` may contain prose that presupposes an earlier version ("based on the feedback, X is now out of scope").
- **Risks belong to the deliverable, questions to `meta.md`.** A plan or strategy stating its own risks is doing its job. Items that need the user's decision, and assumptions made provisionally, are `Q-###` in Part 3. Only when there is no deliverable do risks move into Part 2.
- **Mirror sync.** After any material change, walk the deliverable's sections and confirm each has a current Part 2 block and that no block explains content the deliverable no longer has.
- **TBD is allowed, untracked TBD is not.** Every TBD in the deliverable corresponds to a `Q-###` or a named research item in `meta.md`.
- **Breadth in `sub/`, chain in `meta.md`.** If `meta.md` grows past what a reviewer can read in one sitting, move enumerations, comparisons, and raw findings to `sub/` and leave the reasoning that connects them.
- **Style.** Follow the workspace's Markdown style rules if present. Within them, Part 2 blocks are prose-first because a chain of judgment reads better as connected sentences than as fragments; parallel comparisons still go in tables, and headings are used only for the three parts and the mirrored section blocks.
- **Verify sources** after material changes: every citation in `meta.md` and `sub/` is a resolvable path, link, or `sub/` file; no `record.md` entry number appears outside `record.md`; every `Q-###` in Part 3 is genuinely open and appears nowhere else.

## Examples

- **Theme only.** "リリース前に運用手順を決めておくべきか悩んでいる" → cycle 1 writes Part 1 proposing a short operations runbook as the deliverable, names its reader (the on-call operator) and criteria (can it be followed without the author present; does it stay valid across the next two releases), and asks two `Q-###` about who owns escalation. After the user confirms, cycle 2 drafts `runbook.md`, and Part 2 explains why each procedure is shaped as it is and which alternatives were rejected.
- **Deliverable known.** "外部 API の仕様書を改訂したい" → Part 1 confirms reader, compatibility constraints, and what "revised" means; the deliverable follows the existing spec's format; Part 2 explains each changed clause and the evidence behind it.
- **Consultation ending without a deliverable.** "この機能、そもそも作るべきか" → after research and two dialogue rounds the conclusion is "not now, revisit when X"; `meta.md` records the reasoning and the trigger, status `final`, no deliverable file.

## Common issues

- **The theme drifted into a question about the theme** (e.g. "at what granularity should we define the strategy" instead of the strategy). Cause: drafting began before Part 1 was reviewed. Fix: rewrite Part 1 to name the deliverable, then move the substantive content that accumulated in `sub/` or `meta.md` into the deliverable.
- **`meta.md` reads like a changelog.** Cause: review feedback was applied as local edits and the old reasoning left in place. Fix: for each affected block, recompute from current inputs and rewrite as if writing for the first time; keep the change itself in `record.md` only.
- **`meta.md` or `sub/` cite `record.md` entries as sources.** Cause: the ledger was treated as a citation index. Fix: replace each reference with the primary source (path, link, document) or the `sub/` report, or with the content of what the user said; leave `record.md` as a standalone chronology.
- **The deliverable contains `Q-###` or ledger references.** Fix: remove them; if the reader needs the source, cite the source itself.
- **The user asks to start implementing.** This skill stops at the deliverable. Set status, name the deliverable as the input, and hand off to an implementation workflow; do not begin building inside the desk-loop workspace.
