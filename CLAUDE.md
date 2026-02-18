# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`churn_vs_complexity` is a Ruby gem that analyzes code quality by correlating file churn (how often files change) with complexity scores. It supports Ruby (via Flog), JavaScript/TypeScript (via ESLint), and Java (via PMD). Requires Ruby >= 3.3.

## Commands

```bash
# Run tests (TLDR framework)
bundle exec rake          # default task runs tldr
bundle exec tldr          # direct

# Run a single test file
bundle exec tldr test/churn_vs_complexity/engine_test.rb

# Run a single test by name
bundle exec tldr --name test_something test/path/to_test.rb

# Lint
bundle exec rubocop
bundle exec rubocop -a    # auto-fix safe offenses

# Build/install gem
bundle exec rake build
bundle exec rake install
```

## Architecture

Three operating modes, each with its own Config/Checker/Serializer pipeline:

- **Normal** (`Normal::Config` → `Engine` → `ConcurrentCalculator`): Analyzes a folder, computing churn + complexity per file. Outputs CSV, HTML graph, or text summary.
- **Timetravel** (`Timetravel::Config` → `Traveller`): Samples quality scores across historical commits at N-day intervals. Uses forked processes with git worktrees for isolation.
- **Delta** (`Delta::Config` → `MultiChecker` → `Checker`): Analyzes complexity of files changed in specific commits. Uses threads with git worktrees.

Entry point: `CLI::run!` → `CLI::Parser` → `CLI::Main.run!` → mode-specific Config → checker.

### Key interfaces

- **Complexity calculators**: `folder_based?`, `calculate(folder:)` or `calculate(files:)`
- **Churn calculators**: `calculate(folder:, file:, since:)`, `date_of_latest_commit(folder:)`
- **Serializers**: `serialize(result)`
- **File selectors**: `select_files(folder)` → `{ included: [...], explicitly_excluded: [...] }`

### Concurrency model

- Normal: threads (nprocessors) for per-file churn calculation
- Timetravel: forked child processes with IO.pipe for IPC
- Delta: threads (2x nprocessors) for concurrent commit analysis

## Code Style

RuboCop config (`.rubocop.yml`):
- Max line length: 120
- Trailing commas enforced on multiline (arrays, hashes, arguments)
- `NewCops: enable`
- No class/module documentation required (`Style::Documentation` disabled)
