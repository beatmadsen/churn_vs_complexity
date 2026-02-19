## [1.6.1] - 2026-02-19

### Changed
- Updated gemspec summary and description to reflect all supported languages and modes
- Updated README with current usage, all languages (Ruby, JS/TS, Java, Python, Go), all modes, and new examples
- Added external dependency documentation for Python (radon) and Go (gocyclo)

## [1.6.0] - 2026-02-19

### Added
- Python support for complexity calculation
- Go support for complexity calculation (via gocognit)
- New `--triage` mode: per-file risk assessment based on churn and complexity
- New `--hotspots` mode: ranked list of files by risk score
- New `--gate` mode: pass/fail quality gate with `--max-gamma` threshold (exit 0/1)
- New `--focus start|end` mode: capture complexity snapshots before and after coding sessions
- New `--diff REF` mode: compare codebase health between a reference commit and HEAD
- New `--json` output format for all modes
- New `--markdown` output format
- Risk classifier and risk annotator modules
- Gamma score module

### Fixed
- Improved CLI help text with grouped sections (Languages, Modes, Output formats, Modifiers)

## [1.5.2] - 2024-10-21

- Fixed bug where delta mode validations would fail when the commit was a non-sha value.
- Allow HEAD as specified commit in delta mode

## [1.5.1] - 2024-10-15

- Fix bug where worktree checkout silently failed


## [1.5.0] - 2024-10-14

- Added delta mode to annotate changes in individual commits with complexity
- Moving PMD cache to the OS temp directory

## [1.4.0] - 2024-10-10

- Added timetravel mode to visualise code quality over time
- Added alpha, beta, and gamma scores to summaries
- Fixed broken Ruby complexity calculation

## [1.3.0] - 2024-09-26

- Added support for javascript and typescript complexity calculation using eslint

## [1.2.0] - 2024-09-20

- Fixed bug in CLI where new flags and `--since` would not be recognized
- Improved selection of observations included in the output
- Fixed calculation of churn that would never be zero
- Fixed behavior when --since or short-hand flags were not provided

## [1.1.0] - 2024-09-20

- Introduced `--summary` flag to output summary statistics for churn and complexity
- Introduced `--month`, `--quarter`, and `--year` short-hand flags to calculate churn for different time periods relative to the most recent commit

## [1.0.0] - 2024-06-07

- Initial release
