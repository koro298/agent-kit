# Commit Proposal Format

Keep the proposal compact enough to scan as a whole. Use a heading for the proposal and one heading per commit. Do not create subsections such as “Files,” “Purpose,” or “Verification”; represent those details as nested list items instead.

````markdown
# Commit Proposal

- **Repository state**
  - Branch: `<branch>`
  - Staged: `<compact summary>`
  - Unstaged: `<compact summary>`
  - Untracked: `<compact summary>`
- **Split strategy**: `<why these boundaries and this order were chosen>`
- **Concerns**: `<suspected secrets, conflicts, unresolved issues, or "None">`
- **Excluded from all commits**
  - `<path or hunk>`: `<reason>`
- **Review checklist**
  - Commit boundaries and order are coherent.
  - Each message accurately expresses its diff's purpose.
  - Files and hunks have no unintended omissions or overlaps.
  - No secrets or unintended generated artifacts are included.
  - Verification is proportionate to the risk.

## Commit 1 — `<type>: <Japanese summary>`

- **Purpose**: `<the single outcome delivered by this commit>`
- **Changes**
  - `<concrete change supported by the diff>`
  - `<behavioral, data, or configuration impact>`
- **Files**

  ```text
  <repository-root>/
  ├── path/
  │   ├── file-a
  │   └── file-b
  └── tests/
      └── test-file
  ```

  - Hunk split, when needed:
    - `path/file-a`: `<included change and how it differs from excluded hunks>`
- **Verification**
  - `<planned test, lint, build, or manual check>`
- **Dependencies**: `<earlier or later commit dependencies, or "None">`

## Commit 2 — `<type>: <Japanese summary>`

- **Purpose**: `<the single outcome delivered by this commit>`
- **Changes**
  - `<concrete change supported by the diff>`
- **Files**

  ```text
  <repository-root>/
  └── path/
      └── file-c
  ```

- **Verification**
  - `<planned check>`
- **Dependencies**: `<dependencies or "None">`
````

Use the same structure for a single commit. Keep repository-wide context, exclusions, and the review checklist before the first commit as list items, not additional sections. Write `None` for empty items so reviewers can distinguish an intentional check from an omission. Do not add scope, body, or footer merely to fill out the template.
