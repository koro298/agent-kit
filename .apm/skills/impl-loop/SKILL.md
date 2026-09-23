---
name: impl-loop
description: Carry an implementation request — a design or requirements document (typically a desk-loop deliverable), an issue, or a rough change request ("これを実装して", "この設計書どおりに作って", "この不具合を直して", "機能を追加して") — through to code that has proved itself against a check the agent can run, and hand it over with an explicit list of what could not be verified. Use whenever the work is to change code and the change carries judgment. Do not use for mechanical edits that carry none (formatting, renames, typo fixes), for deciding what to build (desk-loop), or for splitting and writing commits (smart-commit).
argument-hint: A design document, an issue, or the change you want implemented.
---

# Impl Loop

The boundary of this skill is execution. Deciding what to build is desk work and belongs to desk-loop; splitting and recording what was built belongs to smart-commit; how code is written in this language belongs to the repository's own coding rules. What is left is the part in between, and it is where an agent most easily produces something that looks finished and is not.

An agent stops when the work looks done. Unless a check exists that the agent can run and read, "looks done" is the only signal available and the user becomes the verification loop, noticing each defect personally. Everything below replaces that signal with evidence: the input is pinned before the work starts, the pass condition is written before the code, the code proves itself against a check, and whatever could not be proved is named out loud rather than left for the reader to find.

## Workspace

The implementation lands in the repository. Everything the loop produces *about* the implementation lands in one task sheet outside it, and the sheet is never committed.

- Put the sheet where the project already keeps work that is not committed: a directory listed in `.git/info/exclude`, or a documents folder that is part of the editor workspace but outside the code repository. If the project has neither, ask before creating one.
- One sheet per task, named for the task, written in the user's language. It always describes the current state; it is not a log.

| Section | What it holds | Written |
|---|---|---|
| Input | What the implementation derives from: a link to the upstream document, and the facts pinned from it — the files and interfaces involved, what is out of scope, what counts as done. Where there is no upstream document, this section is the spec | Before any code |
| Request and pass conditions | What was asked, and the checks that decide pass or fail. Later instructions are folded in, so the section always states the current target | Before any code |
| Evidence | The check commands and what they printed | As checks run |
| Handover | What was built, and what was not built, not verified, or not reproduced | Before handing over |

## Loop

1. **Pin the input.** Read the upstream document in full before starting; do not work from fragments found by keyword search. Write the Input section: the files and interfaces involved, what is explicitly out of scope, and what counts as done. When there is no upstream document, write the smallest spec that answers those three questions and confirm it with the user before writing code. Skip the sheet entirely for mechanical changes that carry no judgment, such as formatting, renames, and typo fixes.
2. **Write the pass condition before the code.** Name at least one check that returns pass or fail on its own: a test, a build, a type check, a linter, a script that diffs output against a fixture, a screenshot compared against a design. For a bug fix, the first check is a reproducer that fails before the change; if the bug cannot be reproduced, report that instead of guessing at a fix. If no mechanical check can exist for this change, write that in the sheet now, not after the work is done.

   When the change adds or alters something that outlives it — a data model, a public interface, a module boundary — write the intended shape before the code, in the notation the project already uses (DBML for a schema, OpenAPI for an HTTP surface, the project's own type definitions), and name that notation in Input. Where the project has settled on no notation, prefer the place the language already gives the shape — a migration or a schema definition for a data model, type definitions for a public interface — and raise a separate document only for a structure that has no home in the code or that must be shared with people who do not read it, placing it under `docs/` in a directory named for what it holds. A dependency direction has no home in the code: when a change creates a module boundary and no direction is stated, write the direction into the project's own rules in one line before building the boundary. The shape is itself a check: the schema against the migration, the interface description against the routes that exist, the layering rule against the imports. Where nothing durable changes, skip it.
3. **Implement, then make the code prove itself.** Run the check and record what it printed. Report results as evidence — the command, its output, and what that establishes — never as assertion. An implementation that does not pass is dropped and another approach tried; the check is never weakened, narrowed, or skipped to make the work pass. Keep the change inside the scope pinned in step 1.
4. **Hand over with the gaps named.** Fill the Handover section with what was not built, not verified, or not reproduced, and with any decision taken provisionally on the user's behalf. State the same gaps to the user in the handover message rather than only in the sheet. For a change large enough that a reviewer would want a second pair of eyes, have it reviewed in a context that did not produce it, so the work is not graded by what wrote it. Then hand the change to the commit workflow.

When the same kind of failure appears twice in one task, stop repairing the instance and repair what let it through: the spec was ambiguous, the check did not cover the case, or a repository rule is missing. Fixing only the instance guarantees a third occurrence.

## Invariants

- **Evidence, not assertion.** "The tests pass" is not a result; the test output is. Nothing is reported as done without the output that shows it.
- **The check is fixed before the work and does not move afterwards.** Adjusting a check so the implementation passes converts a visible failure into a silent defect.
- **Durable shape is expressed before it is built, and lives with the code.** A data model, a public interface, or a module boundary that exists only inside the implementation cannot be checked, and the next task that touches it will decide it again from scratch.
- **Silence is not a pass.** What was skipped, not built, or not verified is stated in the same breath as what was done.
- **The sheet stays out of the repository and out of the code.** Request text, prompt history, and change-history comments never appear in the implementation.
- **No AI attribution in the code or the commit.** Which portions a tool wrote is not tracked.
- **Coding conventions come from the repository.** This skill neither restates nor overrides them.
- **Scope stays where it was pinned.** Defects found outside it are reported in Handover, not fixed in passing.
- **The sheet describes the current target.** How the target changed during the work is not recorded; the section is rewritten.

## Common issues

- **The work finished on "it looks right".** Cause: step 2 was skipped, so appearance was the only signal available. Fix: write the check, run it, and treat its output as the first honest information about the change.
- **The implementation solved a different problem.** Cause: step 1 was compressed into a one-line reading of the request. Fix: rewrite the Input section from the upstream document, then compare the diff against it.
- **The check passes and the feature does not work.** Cause: the check was written after the implementation and shaped by it. Fix: for a bug, start from a failing reproducer; for a feature, derive the pass condition from the spec before the code exists.
- **The sheet turned into a log.** Cause: each new instruction was appended instead of folded into the current target. Fix: rewrite the section so it states the target as it now stands.
- **Scope grew while implementing.** Cause: a nearby defect was fixed on the way. Fix: revert the extra change and report it in Handover as a separate task.
