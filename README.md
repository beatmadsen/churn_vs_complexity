[![Gem Version](https://badge.fury.io/rb/churn_vs_complexity.svg)](https://badge.fury.io/rb/churn_vs_complexity)

# ChurnVsComplexity

Correlates file churn (how often files change) with complexity scores to identify refactoring hotspots and track codebase health over time. Supports Ruby, JavaScript/TypeScript, Java, Python, and Go.

Modes include hotspots ranking, triage assessment, CI quality gate, diff comparison, focus sessions, and timetravel history.

Inspired by [Michael Feathers' article "Getting Empirical about Refactoring"](https://www.agileconnection.com/article/getting-empirical-about-refactoring).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'churn_vs_complexity'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install churn_vs_complexity

This gem depends on git for churn analysis.

External tool dependencies per language:

- **Ruby**: None (uses [Flog](https://rubygems.org/gems/flog), bundled as a gem dependency).
- **Java**: Requires [PMD](https://pmd.github.io) on the search path as `pmd`. On macOS: `brew install pmd`.
- **JavaScript/TypeScript**: Requires [Node.js](https://nodejs.org) (uses ESLint internally).
- **Python**: Requires [Radon](https://radon.readthedocs.io) on the search path as `radon`. Install with `pip install radon`.
- **Go**: Requires [gocyclo](https://github.com/fzipp/gocyclo) on the search path. Install with `go install github.com/fzipp/gocyclo/cmd/gocyclo@latest`.

## Usage

Execute `churn_vs_complexity` with the applicable arguments. Output in the requested format will be directed to stdout.

```
Usage: churn_vs_complexity [options] folder|file...

Languages:
        --java                       Check complexity of java classes
        --ruby                       Check complexity of ruby files
        --js, --ts, --javascript, --typescript
                                     Check complexity of javascript and typescript files
        --python                     Check complexity of python files
        --go                         Check complexity of go files

Modes (mutually exclusive):
        --timetravel N               Calculate summary for all commits at intervals of N days throughout project history or from the date specified with --since
        --triage                     Assess risk of files based on churn and complexity. Accepts file paths or a folder as arguments.
        --hotspots                   Generate ranked list of files by risk
        --gate                       Pass/fail quality check against gamma threshold (exits 0 on pass, 1 on fail)
        --focus start|end            Capture complexity snapshot before (start) and after (end) a coding session
        --diff REF                   Compare codebase health between REF and HEAD
        --delta SHA                  Identify changes between the specified commit (SHA) and the previous commit and annotate changed files with complexity score. SHA can be a full or short commit hash, or the value HEAD. Can be used multiple times to specify multiple commits.

Output formats:
        --csv                        Format output as CSV
        --graph                      Format output as HTML page with Churn vs Complexity graph
        --summary                    Output summary statistics (mean and median) for churn and complexity
        --json                       Format output as JSON
        --markdown                   Format output as Markdown

Modifiers:
        --excluded PATTERN           Exclude file paths including this string. Can be used multiple times.
        --since YYYY-MM-DD           Normal mode: Calculate churn after this date. Timetravel mode: calculate summaries from this date
    -m, --month                      Calculate churn for the month leading up to the most recent commit
    -q, --quarter                    Calculate churn for the quarter leading up to the most recent commit
    -y, --year                       Calculate churn for the year leading up to the most recent commit
        --max-gamma N                Maximum gamma score threshold for gate mode (default: 25)
        --dry-run                    Echo the chosen options from the CLI
    -h, --help                       Display help
        --version                    Display version
```

Note that when using the `--timetravel` mode, the semantics of some flags are subtly different from normal mode:

* `--since YYYY-MM-DD`: Calculate summaries from this date
* `--month`, `--quarter`, `--year`: Calculate churn for the period leading up to each commit being summarised

Timetravel analysis can take many minutes for old and large repositories.

Summaries in normal mode include a gamma score, which is an unnormalised harmonic mean of churn and complexity. This allows for comparison of summaries across different projects with the same language, or over time for a single project.

Summary points in timetravel mode instead include an alpha score, which is the same harmonic mean of churn and complexity, where churn and complexity values are normalised to a 0-1 range to avoid either churn or complexity dominating the score. The summary points also include a beta score, which is the geometric mean of the normalised churn and complexity values.
## Examples

```bash
# CSV churn vs complexity report for a Ruby project
churn_vs_complexity --ruby --csv my_ruby_project > ~/Desktop/ruby-demo.csv

# Interactive HTML graph for a Java project (excluding generated code)
churn_vs_complexity --java --graph --excluded generated-sources --since 2023-01-01 my_java_project > ~/Desktop/java-demo.html

# Monthly summary for a Python project
churn_vs_complexity --python --summary -m my_python_project

# Top refactoring hotspots ranked by risk
churn_vs_complexity --ruby --hotspots -q my_ruby_project

# CI quality gate (exits 1 if gamma exceeds threshold)
churn_vs_complexity --ruby --gate --max-gamma 30 my_ruby_project

# Triage specific files before a code review
churn_vs_complexity --go --triage src/server.go src/handler.go

# Compare codebase health between a branch and HEAD
churn_vs_complexity --ruby --diff origin/main --summary my_ruby_project

# Focus session: snapshot before and after a coding session
churn_vs_complexity --ruby --focus start my_ruby_project
# ... do some coding ...
churn_vs_complexity --ruby --focus end my_ruby_project

# Timetravel: track quality over time at 30-day intervals
churn_vs_complexity --java -m --since 2019-03-01 --timetravel 30 --graph my_java_project > ~/Desktop/timetravel.html

# Analyse complexity of specific commits
churn_vs_complexity --js --delta HEAD --summary my_js_project
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/beatmadsen/churn_vs_complexity.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
