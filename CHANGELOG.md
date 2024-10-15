## [1.5.1] - 2024-10-15

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