# Account defaults and repository standard for simpsonm09.

set shell := ["bash", "-euo", "pipefail", "-c"]

# List recipes.
default:
    @just --list

# Compare standards/core.md with the other four owner repositories.
core-drift:
    bun scripts/core-drift.ts

# Format this repository.
fmt:
    bun fmt

# Fail when a file needs formatting.
fmt-check:
    bun fmt --check

# Run the checks CI requires.
check: fmt-check
