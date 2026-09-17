---
applyTo: "**/*.py, pyproject.toml"
description: Python コード・テスト・pyproject.toml の規約
---

# Python Coding Guidelines (for AI agents)

These rules apply whenever Python code is written in this repository.

## Core Principles

- Write only the code needed to solve the problem at hand. No speculative abstractions, unused options, or premature generalization
- Prioritize clarity and maintainability. When two solutions are equivalent, choose the simpler one
- Consider algorithmic and memory efficiency when data volume or call frequency makes it necessary. Do not optimize otherwise
- Do not repeat logic (DRY), but do not force shared code for fewer than three similar occurrences

## Comments

Comments explain *why*. *What* the code does is expressed by the code itself and its naming.

Acceptable comments:
- The reason behind an implementation that looks unnatural but is intentional (workarounds, performance decisions, constraints from external specs)
- The rationale for non-obvious algorithms or business rules
- References to external documentation, issues, or specifications

Comments to avoid:
- Restating the code (e.g. `# ユーザーを取得する` directly above `user = get_user()`)
- Section dividers (`# ---- 初期化 ----`)
- Change history (`# 追加`, `# 修正`, `# 2026-09 変更`). That belongs in commit messages
- Commented-out code. Delete it if it is not used
- Information already conveyed by type hints or function names

When tempted to write a comment, first consider whether extracting a function, renaming, or introducing a constant would remove the need for it.
Do not explain magic numbers with comments; give them meaningful constant names.

## Docstrings

- Write docstrings only for public functions, classes, and modules (names not starting with `_`). Do not write them for private functions
- If a one-line summary is sufficient, stop there
- Describe parameters, return values, and exceptions only for what type hints cannot express (units, valid ranges, preconditions, conditions that raise)
- Do not repeat types in the docstring
- Include usage examples only for public APIs whose invocation is non-obvious

```python
def calculate_total(items: list[Item], tax_rate: float = 0.0) -> Decimal:
    """税込み合計金額を返す。

    tax_rate は小数で指定する（8% なら 0.08）。
    items が空、または tax_rate が負の場合は ValueError。
    """
```

## Type Hints

- Annotate every function signature (parameters and return value)
- Use `Any` only when there is no alternative
- Express nullable values as `T | None`
- Run mypy and leave no errors

## Naming and Style

- Follow PEP 8. Delegate formatting and linting to Ruff (line length 88)
- snake_case for functions and variables, PascalCase for classes, UPPER_CASE for constants
- Choose names that convey intent. Avoid abbreviations other than widely recognized ones
- Do not use emoji or symbol characters (✓ ✗ etc.) in output, logs, or code. The only exception is tests that exercise multibyte character handling

## Function and Class Design

- Keep functions and classes focused on a single responsibility
- Never use mutable objects (list, dict) as default arguments
- Aim for five or fewer parameters
- Return early to reduce nesting
- Keep `__init__` free of logic
- Use dataclasses for simple data containers
- Prefer composition over inheritance
- Do not add methods or classes until they are needed

## Error Handling

- Never swallow exceptions. Log or re-raise anything that is caught
- Never use a bare `except:`. Catch specific exception types
- Manage resources with `with`
- Include the information needed to identify the cause in error messages
- Report errors to the console with `logger.error`, not `print`

## Testing

- Use pytest
- Write unit tests for new functions and classes
- Mock slow or environment-dependent dependencies (network APIs, databases, GPU inference, model training) behind the ports defined in the test strategy. Do not mock the local file system; tests use real files under pytest's `tmp_path` so that temp-file-then-rename behavior is verified for real
- Follow the Arrange-Act-Assert pattern
- Save tests as standalone files before running them
- Do not commit commented-out tests

## Imports and Dependencies

- No wildcard imports
- Manage dependencies in `pyproject.toml` and use `uv`
- Import order: standard library, third-party, local (formatted by Ruff)

## Python Idioms

- Compare with `None` / `True` / `False` using `is`
- Format strings with f-strings
- Use `enumerate()` instead of manual counters
- Use list comprehensions and generator expressions where appropriate
- Read and write JSON with `orjson`

## Security

- Never put secrets, API keys, or passwords in code. Keep them in `.env`, and keep `.env` in `.gitignore`
- Never log or print URLs that contain API keys
- Never log passwords, tokens, or personal information

## Version Control

- Write commit messages that convey both the change and its reason
- Do not commit commented-out code, debug prints, or breakpoints
- Do not commit credentials

## Data Science (only for applicable projects)

- Use `polars` instead of `pandas` for data frame manipulation
- When displaying a data frame, do not separately print its row count or schema (redundant)
- Read at most 10 rows when inspecting data
- In Jupyter Notebooks, use `tqdm` for long loops with a description that matches the work being done
- In Jupyter Notebooks, explicitly `print()` data frames inside conditional blocks
- Install `ipykernel` and `ipywidgets` in `.venv`, but do not add them to package dependencies
- Keep database schemas normalized unless instructed otherwise. Use `DATETIME/TIMESTAMP` for dates and `ARRAY` for nested fields; do not stuff them into strings

## Pre-commit Checklist

- [ ] All tests pass
- [ ] mypy passes
- [ ] Ruff formatting and linting pass
- [ ] Public APIs have docstrings and type hints
- [ ] No comments that merely restate what the code does
- [ ] No commented-out code or debug output
- [ ] No hardcoded credentials
