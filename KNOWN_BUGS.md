# Known Bugs

Discovered during integration testing of `--python` and `--go` support against real projects.

## Bug A: `gocognit --help` leaks to stderr on every run

### Severity: Cosmetic

### Problem

Every `--go` run prints ~40 lines of gocognit usage text to stderr. This is confusing for users and pollutes piped output.

### Root cause

`GoCalculator.check_dependencies!` (`lib/churn_vs_complexity/complexity/go_calculator.rb:26`) calls `gocognit --help` via `Open3.capture2`, which captures stdout but not stderr. gocognit prints its help text to stderr.

### Fix

Use `Open3.capture2e` (captures both streams), or check with a command that doesn't produce output (e.g., `gocognit -json /dev/null`).

## Bug B: Reversed diff direction in delta mode

### Severity: Significant

### Problem

In delta mode, files **added** in a commit are missing from the output. Files **deleted** in a commit would incorrectly be included (and likely crash when complexity calculation is attempted on a nonexistent file).

Discovered when `--python --delta HEAD --csv` omitted `test_fatguy.py`, which was added in the HEAD commit.

### Root cause

`GitStrategy#changes` (`lib/churn_vs_complexity/git_strategy.rb:31`) computes the diff in the wrong direction:

```ruby
commit_object.diff(base)
```

This diffs FROM the commit TO its parent, reversing change types:
- Added files appear as `:deleted`
- Deleted files appear as `:new`
- Modified files are unaffected (symmetric)

The `ComplexityAnnotator` then filters out `:deleted` files, so newly added files are silently dropped.

### Fix

Reverse the diff direction: `base.diff(commit_object)`. Handle the initial commit case where `base` is nil.

## Bug C: Short SHA validation rejects 7-character hashes

### Severity: Minor

### Problem

`--delta` rejects the most common short SHA format. `git log --oneline` outputs 7-character SHAs by default, but the validator only accepts exactly 8 characters.

### Root cause

`Delta::Config#validate_commit!` (`lib/churn_vs_complexity/delta/config.rb:41`):

```ruby
commit.match?(/\A[0-9a-f]{8}\z/i)
```

### Fix

Accept a range of short SHA lengths: `/\A[0-9a-f]{7,12}\z/i`.

## Bug D: Churn is 0 when all commits are from the same day

### Severity: Edge case

### Problem

For repositories where all commits happened on the same day, churn is reported as 0 for every file. This is because `git log --since="2026-02-18"` excludes commits from that date (git treats bare dates as midnight, so "since Feb 18" means "after Feb 18 23:59:59").

### Root cause

`Churn` (`lib/churn_vs_complexity/churn.rb:19`) formats the earliest date without a time component:

```ruby
earliest_date = [date_of_first_commit(folder:), since].max
```

The resulting date string passed to `git log --since=` lacks a time component, causing git's date parsing quirk to exclude same-day commits.

### Fix

Append a time component: `earliest_date.strftime('%Y-%m-%dT00:00:00')`.

## Observation: Stale git worktrees from delta mode

### Severity: Low

Delta mode creates git worktrees in temp directories but doesn't always clean them up on exit. Over time these accumulate and may cause non-deterministic behavior if a stale worktree directory is reused. Run `git worktree list` to check for and `git worktree prune` to clean up stale entries.
