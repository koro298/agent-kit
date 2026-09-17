---
name: smart-commit
description: Analyze Git changes, split them into logical commits, prepare Japanese Conventional Commit proposals as reviewable Markdown, and commit safely after Crit review. Use when the user asks to commit changes, plan commit boundaries, review commit proposals, or perform a smart commit.
---

# Smart Commit

Analyze the actual changes, propose logically separated commits, and commit only the reviewed or otherwise authorized plan. Respect the user's existing staging state and working tree contents.

## Defaults

- Use Conventional Commits in the form `<type>: <Japanese summary>`.
- Do not include a scope or body by default. Include one only when the user requests it, repository rules require it, or it is essential to understanding the change.
- Do not include a footer by default. Use a footer only when semantically or operationally required, such as for a breaking change or issue reference.
- Never add assistance, co-authorship, or AI-generation attribution, including variants of `Assisted-by`, `Co-authored-by`, and `Generated-by`.
- Write a concise Japanese subject, aiming for no more than 72 characters. Choose the type from `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`.
- Mark a breaking change with `!` immediately after the type. Add a `BREAKING CHANGE:` footer only when needed, and call it out in the proposal.

Follow an explicit user choice of message language or format. Always retain the attribution prohibition and safety rules.

## Workflow

### 1. Collect changes

Gather the current state without modifying it. At minimum, inspect:

```bash
git status --short --branch
git diff --stat
git diff
git diff --staged
git ls-files --others --exclude-standard
```

- Keep staged, unstaged, and untracked changes distinct. Read relevant untracked file contents because they do not appear in a normal diff.
- Check applicable repository instructions and commit conventions, as well as any merge, rebase, cherry-pick, or unresolved conflict in progress.
- Do not change the staging area during this step.
- Check for secrets and sensitive material such as `.env` files, credentials, private keys, tokens, and personal data. Do not display secret values. Report only the suspect path and reason, exclude it from the plan, and stop if safety cannot be established.

### 2. Analyze changes and prepare the commit plan

Keep each commit to one logical change. Keep together changes that must land together, such as an implementation with its tests or a dependency declaration with its lockfile. Separate unrelated fixes, formatting, and documentation. If independent changes within one file require hunk-level separation, state the boundaries and rationale.

Create a reviewable Markdown file. Prefer an existing ignored work directory; otherwise use a temporary directory outside the repository. Never include the proposal file itself in a commit.

Read and follow the compact [commit proposal format](references/commit-proposal.md). The proposal must include:

- The current branch and a compact summary of staged, unstaged, and untracked changes.
- Commit order and the reason for the split.
- The complete commit message for every commit.
- A file tree for every commit, with hunk-level boundaries when applicable.
- The purpose and concrete changes for every commit.
- Excluded changes, suspected sensitive material, unresolved concerns, and planned verification.

Do not invent changes that the diff does not support. Confirm that every intended file appears exactly once unless a documented hunk split places the same file in multiple commits.

### 3. Open the commit plan for review

By default, launch Crit with the Markdown proposal as the review target. If Crit cannot be invoked in the current environment, present the Markdown and wait for explicit user approval. Do not commit before review.

Applicable `AGENTS.md` instructions, equivalent project instructions, or the current user's explicit instructions may require or allow skipping Crit and user review. Honor such an instruction and proceed without review. Unless the same instruction also says not to create a proposal, still complete step 2 so an auditable plan remains. Never infer review bypass merely for convenience.

When review requests changes, return to step 2, update the same Markdown file, and reopen it for review. Repeat until approved. Treat review comments as changes to the proposal first, not as permission to edit the staging area or working tree.

If the original request includes committing and Crit approves the plan, treat that approval as authorization to execute only the approved plan. The same applies when review bypass is explicit and the original request includes committing. Otherwise, obtain explicit authorization before execution.

### 4. Execute the commits

Immediately before execution, refresh the status and diffs. If they differ from the reviewed plan, return to step 2.

For each approved commit, in order:

1. Stage only the approved paths or hunks. Even when the approved plan reorganizes existing staging, never discard working tree content.
2. Inspect `git diff --staged` and run `git diff --staged --check` to verify content, boundaries, secrets, and whitespace errors.
3. Run the smallest relevant tests, lint checks, and builds appropriate to the repository and change risk. Report checks that cannot be run.
4. Commit with the approved message exactly as written.
5. Inspect `git show --stat --oneline HEAD` and `git status --short` to verify the result and remaining changes.

If a hook fails, do not bypass it with `--no-verify`. Reanalyze hook edits or new diffs, returning to step 2 when they materially change the plan. Never amend an existing commit without explicit authorization.

## Git safety protocol

- Never update Git configuration.
- Never use `--force`, hard reset, history rewriting, or content-discarding operations without an explicit request.
- Never skip hooks with `--no-verify` unless the user explicitly requests it.
- Never force-push to main or master.
- Never commit secrets. Stop and report any unresolved suspicion.
- Never stage or commit files outside the authorized plan.
- Prefer explicit paths and reviewable hunks over broad adds, globs, or opaque interactive operations.
- Never hide a failure by creating an empty commit, amending, or adding an unplanned follow-up commit.

## Attribution

Based on the MIT-licensed [`git-commit` skill](https://github.com/github/awesome-copilot/blob/main/skills/git-commit/SKILL.md) from GitHub's `awesome-copilot`, retaining its Conventional Commits approach and Git safety principles.
