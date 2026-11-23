# simpsonm09/.github working agreements

This repository holds the account-wide GitHub community defaults for
`simpsonm09` and the written repository standard for the account: the shared
core plus this owner's choices.

## Commands

- `just` lists recipes.
- `just install` installs the pinned tools from `mise.toml`.
- `just fmt` formats; `just fmt-check` fails when a file needs formatting.
- `just agent-files` checks `.agents/skills` against `.claude/skills`.
- `just check` runs what CI would require: `fmt-check` and `agent-files`.
- `just core-drift` compares `standards/core.md` with the other four owners.

## Invariants

- `standards/core.md` and `scripts/core-drift.ts` are verbatim copies. Never edit
  them in this repository. A core change goes to all five owner `.github`
  repositories in one pull request each with identical content, and
  `just core-drift` must pass before merge.
- `standards/owner.md` is this account's standard. Keep it aligned with live
  GitHub state and with the conformance backlog it carries.
- `docs/exceptions.md` lists the rules this repository cannot meet, with reasons and
  revisit dates. Keep it current.
- Do not add workflows. This repository has no CI by design; `just check` is the
  local gate.
- Keep the existing community files unchanged. They are the account defaults
  other repositories inherit.
