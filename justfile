# Account defaults and repository standard for simpsonm09.

set shell := ["bash", "-euo", "pipefail", "-c"]

# List recipes.
default:
    @just --list

# Install the pinned tools from mise.toml. There is no package manager.
install:
    mise install

# Compare standards/core.md with the other four owner repositories.
core-drift:
    bun scripts/core-drift.ts

# Audit every repository of this owner against the core and owner standards.
# `just fleet-audit --timing` adds the C5.1 median pull request CI wall time.
fleet-audit *args:
    bun scripts/fleet-audit.ts {{args}}

# Format this repository.
fmt:
    bun fmt

# Fail when a file needs formatting.
fmt-check:
    bun fmt --check

# Check the agent skill files: frontmatter, recipes and the .claude symlinks.
agent-files:
    bun scripts/agent-files.ts

# Run the checks CI requires.
check: fmt-check agent-files
