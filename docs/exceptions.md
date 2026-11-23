# Exceptions

Rules from [`standards/core.md`](../standards/core.md) and
[`standards/owner.md`](../standards/owner.md) that this repository cannot meet, with the reason and
the date to revisit.

| Rule       | Reason                                                                                                                                                                                         | Revisit    |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| C2.2, C5.1 | The repository is documentation and community defaults only and the owner standard gives it no CI, so there is no required check and no median to report. The pull request itself is the gate. | 2027-02-23 |
| C7.5       | `lint`, `typecheck`, `test` and `hooks` have nothing to run: there is no code, no dependency manifest and no workflow. `install`, `fmt`, `fmt-check`, `check` and `agent-files` exist.         | 2027-02-23 |
| C3.2       | `dependabot.yml` covers `github-actions`, but the repository has no workflows yet, so it opens no pull requests. It is in place for the first workflow.                                        | 2027-02-23 |
