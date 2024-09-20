## [1.0.0] - 2024-06-07

- Initial release

## [1.1.0] - 2024-09-20

- Introduce `--summary` flag to output summary statistics for churn and complexity
- Introduce `--month`, `--quarter`, and `--year` short-hand flags to calculate churn for different time periods relative to the most recent commit

## [1.2.0] - 2024-09-20

- Fix bug in CLI where new flags and `--since` would not be recognized
- Improve selection of observations included in the output
- Fixed calculation of churn that would never be zero
