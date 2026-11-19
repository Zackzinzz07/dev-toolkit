---
name: agy-worker
description: Delegate coding, refactoring, test writing, documentation, boilerplate, code search and bulk file reading to the Google Antigravity CLI (`agy`) as a headless subagent. Use this skill whenever a task involves writing or changing code, reading many files, generating tests or docs, or investigating a bug — even if the user does not mention `agy` or Antigravity. Claude acts as orchestrator (plan, pick model, dispatch, review); `agy` does the heavy lifting.
---

# agy-worker

Claude is the orchestrator; `agy` (Google Antigravity CLI) is the executor. Delegating saves Claude's context and tokens, and lets independent jobs run in parallel. Claude's job is to plan, choose the model, dispatch, **review the result**, and fix only small details.

## Flags (verified with `agy --help` and `agy models`)

| Flag | Use |
|---|---|
| `-p "<prompt>"` (`--print`) | Run one prompt non-interactively and print the answer. Always use this for delegation. |
| `--model <id>` | Select the model (ids below). |
| `--effort low\|medium\|high\|xhigh\|max` | Reasoning effort for the session. |
| `--mode accept-edits\|auto\|plan` | Execution mode. `accept-edits` for edits; `plan` for read-only analysis. |
| `--dangerously-skip-permissions` | Auto-approves every tool request. **Do not use by default**: Claude Code's safety classifier blocks it, and `--mode accept-edits` already covers file edits headlessly. Only use it if the user explicitly asks. |
| `--add-dir <dir>` | Add another directory to the workspace (repeatable). |
| `--output-format text\|json\|stream-json` | Output format in print mode. |
| `--print-timeout <dur>` | Time limit, e.g. `10m`. `0` = no limit. |
| `-c` / `--conversation <id>` | Continue the latest / a specific conversation (follow-up fixes). |
| `--sandbox` | Run with terminal restrictions. |

Run `agy models` to refresh the list — ids change between versions.

## Choosing the model

Models found on this install: `gemini-4-argon-{low,medium,high}`, `gemini-3.8-flash-{low,medium,high}`, `claude-opus-5-5-*`, `claude-sonnet-5-5-*`, `gpt-oss-120b-medium`. There is no model literally named "Pro"; `gemini-4-argon` is the top Gemini tier and plays that role.

| Task type | Model |
|---|---|
| Complex work: architecture, heavy refactors, hard debugging, multi-file design | `gemini-4-argon-high` (use `--effort high`/`xhigh` for the hardest cases) |
| Moderate work, unclear difficulty | `gemini-4-argon-medium` |
| Fast work: tests, docs, boilerplate, searches, summarizing files, renames | `gemini-3.8-flash-medium` (`gemini-3.8-flash-low` for trivial lookups) |

Fast, cheap models are good enough for well-specified mechanical tasks; reserve the big model for work where wrong reasoning is expensive.

## Writing the prompt

`agy` starts with no memory of this conversation, so the prompt must be self-contained:
- Goal and the expected end state.
- Exact files/dirs in scope and what must NOT be touched.
- Conventions to follow (point to CLAUDE.md or an example file).
- How to verify (test/lint command to run).
- What to report back (short summary of changes and anything uncertain).

## Single task

```bash
agy -p "<self-contained prompt>" \
  --model gemini-4-argon-high \
  --mode accept-edits \
  --print-timeout 15m
```

For read-only investigation, use `--mode plan`. In `accept-edits` the agent edits files but may not run shell commands, so tell it "do not run commands" in the prompt and run tests yourself afterwards.

## Parallel tasks

Only parallelize tasks that touch **different files** — two agents editing the same file will clobber each other. Use separate logs:

```bash
mkdir -p .agy-logs
agy -p "Write unit tests for src/a.ts" --model gemini-3.8-flash-medium \
  --mode accept-edits > .agy-logs/tests-a.log 2>&1 &
agy -p "Document the public API in src/b.ts" --model gemini-3.8-flash-medium \
  --mode accept-edits > .agy-logs/docs-b.log 2>&1 &
agy -p "Refactor src/c.ts to remove duplication" --model gemini-4-argon-high \
  --mode accept-edits > .agy-logs/refactor-c.log 2>&1 &
wait
tail -n 40 .agy-logs/*.log
```

Add `.agy-logs/` to `.gitignore` if it is not there already.

## Mandatory review after every run

The subagent can be wrong or overreach, so never accept its work unseen:

1. `git status` — confirm only the expected files changed (and no stray files).
2. `git diff` — read the actual changes; check against the requested scope.
3. Run the project's tests/lint if applicable.
4. Small defects: fix them yourself. Larger defects: re-dispatch with a sharper prompt (`agy -c -p "..."` to continue the same conversation).

Report to the user what was delegated, to which model, and what the review found.

## Skills available inside `agy`

`agy` loads skills from `~/.gemini/config/skills/` (global) and `<repo>/.agents/skills/` (project). Name the skill in the prompt so it is actually used, e.g. "Use a skill frontend-design para...".

| Task | Skill to name in the prompt |
|---|---|
| UI / pages / components | `frontend-design`, `tailwind-patterns` |
| Browser E2E, screenshots, UI checks | `playwright-skill`, `webapp-testing`, `browser-testing-with-devtools` |
| Bugs, failing tests | `systematic-debugging`, `debugging-and-error-recovery` |
| New features / tests | `test-driven-development` |
| Before declaring done | `verification-before-completion` |
| Review, security, perf | `code-review-and-quality`, `security-and-hardening`, `api-security-best-practices`, `web-performance-optimization` |
| Data / infra | `database-design`, `docker-expert` |
| Planning | `brainstorming`, `writing-plans` |

The full library (~1840 skills) lives in `~/.agents/skills/`; to enable another one, symlink it: `ln -sfn ~/.agents/skills/<name> ~/.gemini/config/skills/<name>`. Keep the active set small — each loaded skill costs prompt context.
