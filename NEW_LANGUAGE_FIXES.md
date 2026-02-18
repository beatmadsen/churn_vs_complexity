# New Language Fixes

Issues found while testing `--python` and `--go` support, with proposed solutions.

## Bug 1: Missing dependency check for Python and Go

### Problem

When `radon` (Python) or `gocognit` (Go) is not installed, the gem crashes with a Ruby `JSON::parse` stack trace:

```
/lib/churn_vs_complexity/complexity/python_calculator.rb:17:in 'JSON::Ext::Parser.parse'
```

Both calculators already define `check_dependencies!` with friendly error messages (e.g., `"Needs radon installed (pip install radon)"`), but these methods are never called.

### Root cause

`ComplexityValidator.validate!` (`lib/churn_vs_complexity/complexity_validator.rb`) only handles `:java` and `:javascript`. The `:python` and `:go` cases are missing — they were not added when the new languages were introduced.

```ruby
# Current code
def self.validate!(language)
  case language
  when :java
    Complexity::PMD.check_dependencies!
  when :javascript
    Complexity::ESLintCalculator.check_dependencies!
  end
end
```

### Fix

Add the missing cases:

```ruby
def self.validate!(language)
  case language
  when :java
    Complexity::PMD.check_dependencies!
  when :javascript
    Complexity::ESLintCalculator.check_dependencies!
  when :python
    Complexity::PythonCalculator.check_dependencies!
  when :go
    Complexity::GoCalculator.check_dependencies!
  end
end
```

One file, two lines. Tests for `check_dependencies!` already exist in `go_calculator_test.rb`; add a corresponding test for the validator.

## Bug 2: Calculators hang indefinitely when external tool is missing

### Problem

When `gocognit` or `radon` is not on PATH and the dependency check is skipped (Bug 1), the calculator shells out via backticks and hangs indefinitely waiting for a response that never comes. During testing, three background bash processes (`--go --summary`, `--go --csv`, `--go --graph`) became stuck and had to be manually killed.

This is worse than a crash — a crash is at least visible. A hang is silent and wastes resources (stuck processes, blocked agents, leaked file handles).

### Root cause

Both `GoCalculator.run_gocognit` and `PythonCalculator.run_radon` use backtick execution with no timeout:

```ruby
def run_gocognit(files)
  files_arg = files.map { |f| "'#{f}'" }.join(' ')
  `gocognit -json #{files_arg}`
end
```

When the command is not found, the backtick call may behave unpredictably depending on shell and environment — sometimes it returns empty string (causing the JSON parse crash), sometimes it hangs.

### Fix

Replace backtick execution with `Open3.capture2` or `Open3.capture3` with a timeout, and check the exit status:

```ruby
def run_gocognit(files)
  files_arg = files.map { |f| "'#{f}'" }.join(' ')
  stdout, status = Open3.capture2("gocognit -json #{files_arg}")
  raise Error, "gocognit failed (exit #{status.exitstatus}). Is it installed?" unless status.success?
  stdout
end
```

This gives a clear error on failure instead of hanging or producing empty output. The same pattern should be applied to `PythonCalculator.run_radon`.

Combined with the Bug 1 fix (calling `check_dependencies!` up front), this becomes a belt-and-suspenders defense: the dependency check catches the common case early, and the `Open3` guard catches unexpected runtime failures.

## Bug 3: Python venv directories included in analysis

### Problem

Running `--python` on a project with a virtual environment (`venv/`) analyzes thousands of vendored `.py` files. A project with 2 source files produced 5,154 observations, ~797KB of CSV, and meaningless statistics (mean churn near zero because vendored files have no git history).

The `--excluded venv` workaround fixes it, but users shouldn't need to know this.

### Root cause

`FileSelector::Excluding` (`lib/churn_vs_complexity/file_selector.rb`) uses `Dir.glob("#{folder}/**/*")` with no awareness of language-specific conventions. Python virtual environments (`venv/`, `.venv/`, `env/`) contain thousands of `.py` files that are dependencies, not source code.

### Proposed solutions (pick one)

**Option A: Default excludes per language.** Add a class method to each `FileSelector` language module that returns default exclude patterns. For Python: `['venv/', '.venv/', 'env/', '.env/', '__pycache__/', '.tox/', 'site-packages/']`. These get merged with any user-supplied `--excluded` patterns.

```ruby
module Python
  DEFAULT_EXCLUDES = %w[venv .venv env .env __pycache__ .tox site-packages].freeze

  def self.excluding(excluded)
    Excluding.new(FileSelector.extensions(:python), DEFAULT_EXCLUDES + excluded)
  end
end
```

This approach is simple and predictable. Other languages could add their own defaults later (e.g., `node_modules/` for JS — though ESLint may already handle this, `vendor/` for Go).

**Option B: Respect `.gitignore`.** Use `git ls-files` or parse `.gitignore` to determine which files are tracked. This handles all ignore patterns automatically but introduces a git dependency into file selection (currently only churn calculation uses git).

**Recommendation: Option A.** It's explicit, requires no new dependencies, and matches how tools like `ruff`, `black`, and `gofmt` handle this — they all ship with default excludes for their ecosystem. Option B could be layered on later if needed.

## Non-bug: `--delta` requires a serializer but doesn't say which

### Observation

Running `--delta HEAD` without `--csv`, `--summary`, or `--graph` produces:

```
No serializer selected. Use --help for usage information.
```

This is the same behavior as Normal mode without a serializer — it's consistent, not a bug. But it is a minor UX papercut since `--delta` only supports `--csv` in practice (the others don't make sense for per-commit output). Could be addressed later by defaulting delta to CSV output when no serializer is specified.
