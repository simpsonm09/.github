# simpsonm09 repository standard

This is the professional personal account of one developer. It holds the public
profile landing page, general-use programming tools, and forks of other people's
projects: coding-focused, but lighter than the `simpsonm09-projects` organization.
`standards/core.md` applies in full unless a **(profile)** rule is adjusted below.

## Scope

Live `gh repo list simpsonm09` on 2026-11-23: four repositories, all public, none
archived.

| Repository                          | Visibility | Kind                                   | Notes                                                                             |
| ----------------------------------- | ---------- | -------------------------------------- | --------------------------------------------------------------------------------- |
| `simpsonm09/.github`                | public     | Account defaults and this standard     | Community defaults only; no workflows before this change                          |
| `simpsonm09/simpsonm09`             | public     | Profile landing page                   | README plus `.env.example` and `.worktreeinclude`; not the `/profile/` repository |
| `simpsonm09/steam-wishlist-cleanup` | public     | General-use tool (Python)              | Moved from the `simpsonm09-projects` organization on 2026-11-23; no tests or CI   |
| `simpsonm09/pstack-max`             | public     | Fork of `michael-denyer/pstack-claude` | Upstream MIT license; the fork adds OpenCode, T3, and Windows Copilot support     |

The organization standard in `simpsonm09-projects/repo-standard` is out of scope
here. It covers organization repositories only.

## Plan and protection

GitHub Free. A repository ruleset can protect a public repository on Free;
private repositories would need Pro or Team. All four repositories are public, so
each gets a ruleset named `protect-main` and no repository falls back to local
enforcement.

`protect-main` targets `main` and has no bypass actors. It enforces:

| Setting                       | Value                                                                           |
| ----------------------------- | ------------------------------------------------------------------------------- |
| Require a pull request        | On, 0 approving reviews                                                         |
| Allowed merge method          | Squash only (merge commits and rebase merges are off in repository settings)    |
| Required status checks        | The repository's own check jobs, listed below; no strict up-to-date requirement |
| Require signed commits        | On                                                                              |
| Block branch deletion         | On                                                                              |
| Block non-fast-forward pushes | On                                                                              |
| Bypass list                   | Empty; no user, team, app, or organization admin has one                        |

Alongside the ruleset, repository settings are: `main` as default branch,
delete head branches on merge, auto-merge on, Dependabot alerts and security
updates on, secret scanning and push protection on, CodeQL default setup on,
actions pinned to full SHAs required, and the default `GITHUB_TOKEN` read-only.

If a private repository appears on this Free account, rulesets are unavailable.
C2.1 is then enforced by all three of:

1. A committed `lefthook.yml` that loads `hooks/core.yml` and `hooks/owner.yml`
   through `remotes` at the `hooks-v3` tag and is installed by `just hooks`. Its
   `core-policy` job rejects a push to `main` and runs `gitleaks` on the outgoing
   commits.
2. A `direct-push-guard.yml` workflow that fails on any push to `main` and opens
   an issue naming the pushed commits.
3. A label-driven `automerge.yml` workflow that enables auto-merge for a
   Dependabot pull request carrying `dependencies` once its checks pass, because
   native auto-merge for the workflow is the only plan-supported path.

No private repository exists today. This paragraph is the fallback, not a
current configuration.

## Profile choices

| Rule | Choice                                                                                                                         |
| ---- | ------------------------------------------------------------------------------------------------------------------------------ |
| C1.5 | Issues are on. Wiki, Projects, and Discussions are off in every repository, including the two documentation-only repositories. |
| C2.7 | Commits are signed with SSH keys and `protect-main` requires signatures. Every commit reachable from `main` is signed.         |

## Required checks

A repository with code has one `ci.yml`. It runs independent jobs in parallel, and
each job calls a `just` recipe:

| Job and required context | Command                                                | Recipe           |
| ------------------------ | ------------------------------------------------------ | ---------------- |
| `fmt-check`              | `bun fmt --check`, or `ruff format --check` for Python | `just fmt-check` |
| `lint`                   | `bun lint --no-script`, or `ruff check`                | `just lint`      |
| `typecheck`              | `bun check`, or `mypy src`                             | `just typecheck` |
| `test`                   | `bun test`, or `pytest`                                | `just test`      |
| `build`                  | `bun build`; only where the repository ships an app    | `just build`     |

Required contexts are exactly the job names present in that repository.

| Repository               | Required contexts                                                                                                                                                                    | Notes                                                                                                     |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------- |
| `steam-wishlist-cleanup` | `fmt-check`, `lint`, `typecheck`, `test`                                                                                                                                             | Python tool; no build job                                                                                 |
| `pstack-max`             | `Generated files current`, `Fork registry`, `Skills-only install`, `Pi extension types`, `Vendored bun tooling`, `Shell scripts`, `Workflow lint`, `Markdown lint`, `Markdown links` | Keeps upstream's `CI` workflow. Its Windows and macOS jobs are not required (C5.4).                       |
| `simpsonm09/.github`     | None                                                                                                                                                                                 | No code. Ruleset still requires a pull request, a signature, squash, and no deletion or non-fast-forward. |
| `simpsonm09/simpsonm09`  | None                                                                                                                                                                                 | README only. Same ruleset without status checks.                                                          |

CI is budgeted at under 60 seconds of required-check wall clock (C5.1).
`steam-wishlist-cleanup` has no runs yet. `pstack-max` does not meet the budget
while it keeps upstream's OS matrix: the median of its last 16 pull request runs
was 126 s, and the longest two were about 4.9 h on runner queue. The listed Linux
jobs are the required set; the C5.5 exception records the measurement until the
required set runs under 60 s.

## Git hooks

Hooks run through Lefthook, pinned in `mise.toml` as `"aqua:evilmartians/lefthook"` (C7.8). Each
repository's `lefthook.yml` loads `hooks/core.yml` and `hooks/owner.yml` from this repository
through `remotes` at the annotated tag `hooks-v3`, and adds its own jobs under names that never
start with `core-` or `owner-`. Repositories migrate from the old `.githooks` launchers to Lefthook
per core C7.8.

This owner's `hooks/owner.yml` job runs before every commit:

| Job             | Recipe               | Behaviour                                                                                                                                       |
| --------------- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `owner-signing` | `just signing-check` | Fails when `commit.gpgsign` is not true or `user.signingkey` is unset for this checkout, because `protect-main` requires signed commits (C2.7). |

`just hooks` removes a local `core.hooksPath` only when it equals `.githooks`, refuses any other
value or a global one, runs `lefthook install`, and then asserts that `lefthook dump` contains the
`core-*` and `owner-*` jobs, because a failed remote fetch only warns. `lefthook-local.yml` is
git-ignored, and agents never skip hooks: no `LEFTHOOK=0`, no `--no-verify` (C7.11).

## Owner rules

- **O1 Protection for every public repository.** Every repository gets
  `protect-main` with the contents above and no bypass actors. There is no
  "legacy", "tool", or "fork" exemption. Native auto-merge is enabled for
  Dependabot minor and patch updates (`dependencies` label), never for majors.
  CodeQL default setup, secret scanning, and push protection are on.
- **O2 General-use tools ship like products.** A tool such as
  `steam-wishlist-cleanup` has a README with install and usage sections, an MIT
  `LICENSE`, and semver tags (`vX.Y.Z`) with a GitHub release when it publishes
  anything. Nothing is tagged before its first release.
- **O3 Forks keep upstream's shape.** `pstack-max` keeps upstream's default
  branch (`main`) and MIT license, including the bundled upstream license files.
  Our changes land on a branch named in its `AGENTS.md` and merge through a pull
  request. Upstream syncs also go through a pull request. Fork-specific rules
  (build names, sync boundary, branch names) live in `AGENTS.md`, not in this
  file.
- **O4 Lighter CI than the organization.** One `ci.yml` with parallel jobs that
  call `just` recipes, under 60 seconds. No `flint`, no `aislop`, no Trivy, and
  no coverage gate; those remain organization-only.
- **O5 The profile repository stays a page.** `simpsonm09/simpsonm09` has a
  README, no CI, and no required checks. Its no-CI status is an explicit
  exception, recorded in the backlog until it has a `docs/exceptions.md`.
- **O6 Know the boundary.** The organization catalog's `owned-repositories.json`
  and `owned-forks.json` mention `simpsonm09/simpsonm09` and
  `simpsonm09/pstack-max` at agent access `propose`. Those entries grant nothing:
  the organization standard excludes personal repositories. This standard is the
  authority for them, and O6 is the follow-up that aligns the catalog.

## Superseded

No standard previously covered this account. The organization's
`repo-standard/docs/github-settings.md` says the standard covers organization
repositories only, and a personal repository is out of scope. The organization
`repo-catalog` nevertheless listed `simpsonm09/simpsonm09` in
`owned-repositories.json` and `simpsonm09/pstack-max` in `owned-forks.json` at
`propose`; neither repository had a ruleset, a required check, or an `AGENTS.md`,
so the listing was intent only.

This standard replaces that intent for the account. It changes current practice:

- Merge commits and rebase merges become squash only.
- Unsigned commits become signed and required.
- No branch protection becomes `protect-main` with no bypass.
- Auto-merge off becomes native auto-merge for Dependabot minor and patch.
- No agent instructions becomes one `AGENTS.md` per repository.
- No CI becomes one `ci.yml` for repositories with code.

Follow-up in another repository, not done here: update the organization
`repo-catalog` so its personal-repository and fork entries point at this
standard, or remove those entries, and record that the organization standard does
not govern personal repositories.

## Conformance backlog

Fresh look at the local clones on 2026-11-23, plus the live API state. Times are
from the last 20 recorded runs per repository in `/tmp/repo-audit/api`.

| Repository               | Gaps against core and this standard                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Proposed fix                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `simpsonm09/.github`     | No `protect-main`; wiki and projects on; no topics; no `LICENSE`; Dependabot alerts off; no `dependabot.yml`; merge and rebase merges on; delete-branch off; no `AGENTS.md` or `favicon.svg` before this change; no CI                                                                                                                                                                                                                                                                                  | Apply `protect-main` with no required contexts; squash only; delete branches; add MIT `LICENSE`, topics, and `dependabot.yml`; turn off wiki and projects; record the no-CI exception in `docs/exceptions.md`. CI median: not applicable, no workflows                                                                                                                                                                                                  |
| `simpsonm09/simpsonm09`  | No `protect-main`; no `LICENSE`; wiki and projects on; merge and rebase merges on; no `AGENTS.md`, `favicon.svg`, `.editorconfig`, or `.gitattributes`; no CI by design; Actions disabled                                                                                                                                                                                                                                                                                                               | Apply `protect-main` without checks; squash only; add MIT `LICENSE`, `AGENTS.md`, `favicon.svg`, `.editorconfig`, and `.gitattributes`; turn off wiki and projects; record the profile no-CI exception. CI median: not applicable, no workflows                                                                                                                                                                                                         |
| `steam-wishlist-cleanup` | No `protect-main`; secret scanning and push protection **disabled**; Dependabot alerts off; no `dependabot.yml`; wiki and projects on; merge and rebase merges on; delete-branch off; no `justfile`, `mise.toml`, `AGENTS.md`, `favicon.svg`, `.editorconfig`, tests, or CI; README install and usage are present but use raw `pip` and `python`; no topics; no semver tag or release yet                                                                                                               | Turn on secret scanning, push protection, and Dependabot alerts; add grouped weekly `dependabot.yml`; apply `protect-main` with the four check jobs; add `justfile`, `mise.toml` (Python 3.12, ruff, mypy, pytest), `ci.yml`, `AGENTS.md`, `favicon.svg`, `.editorconfig`, tests, and topics; rewrite README commands through `just`; tag `v1.0.0` when it next ships. CI median: none, no runs                                                         |
| `pstack-max`             | No `protect-main`; issues off; wiki and projects on; no topics; Dependabot alerts off; `dependabot.yml` covers only actions, with no grouping, no Monday schedule, `ci` prefix, and `default-days: 7`; auto-merge off; delete-branch off; no `AGENTS.md` (uses `CONTEXT.md`); no `justfile` or `mise.toml`; no `favicon.svg`; CodeQL default setup not configured; no tags or releases although the package ships 0.9.99; CI pins Bun 1.3.14 while this account pins 1.4.5; required-check median 126 s | Apply `protect-main` with the Linux CI jobs only; turn issues on and wiki and projects off; add topics; add `AGENTS.md` with fork branch and sync rules; add `justfile` and `mise.toml` wrappers; enable Dependabot alerts and a grouped weekly config; turn on CodeQL default setup; tag `v0.9.99` and release from `CHANGES.md`; record the C5.5 exception with the 126 s median; keep upstream's default branch, `CI`, `Security`, and license files |
