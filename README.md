[![Gem Version](https://badge.fury.io/rb/churn_vs_complexity.svg)](https://badge.fury.io/rb/churn_vs_complexity)

# ChurnVsComplexity

A tool to visualise code complexity in a project and help direct refactoring efforts.

Inspired by [Michael Feathers' article "Getting Empirical about Refactoring"](https://www.agileconnection.com/article/getting-empirical-about-refactoring) and the gem [turbulence](https://rubygems.org/gems/turbulence) by Chad Fowler and others.

This gem currently supports analysis of Java, Ruby, JavaScript, and TypeScript repositories, but it can easily be extended.

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

Complexity analysis for Java relies on [PMD](https://pmd.github.io). In order to use the `--java` flag, you must first install PMD manually, and the gem assumes it is available on the search path as `pmd`. On macOS, for example, you can install it using homebrew with `brew install pmd`.

Complexity analysis for JavaScript and TypeScript relies on [ESLint](https://eslint.org). In order to use the `--js`, `--ts`, `--javascript`, or `--typescript` flag, you must have Node.js installed.

## Usage

Execute the `churn_vs_complexity` with the applicable arguments. Output in the requested format will be directed to stdout.

```
Usage: churn_vs_complexity [options] folder
        --java                       Check complexity of java classes
        --ruby                       Check complexity of ruby files
        --js, --ts, --javascript, --typescript
                                     Check complexity of javascript and typescript files
        --csv                        Format output as CSV
        --graph                      Format output as HTML page with Churn vs Complexity graph
        --summary                    Output summary statistics (mean and median) for churn and complexity
        --excluded PATTERN           Exclude file paths including this string. Can be used multiple times.
        --since YYYY-MM-DD           Normal mode: Calculate churn after this date. Timetravel mode: calculate summaries from this date
    -m, --month                      Calculate churn for the month leading up to the most recent commit
    -q, --quarter                    Calculate churn for the quarter leading up to the most recent commit
    -y, --year                       Calculate churn for the year leading up to the most recent commit
        --timetravel N               Calculate summary for all commits at intervals of N days throughout project history or from the date specified with --since
        --delta SHA                  Identify changes between the specified commit (SHA) and the previous commit and annotate changed files with complexity score. SHA can be a full or short commit hash, or the value HEAD. Can be used multiple times to specify multiple commits.
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

`churn_vs_complexity --ruby --csv my_ruby_project > ~/Desktop/ruby-demo.csv`

`churn_vs_complexity --java --graph --exclude generated-sources --exclude generated-test-sources --since 2023-01-01 my_java_project > ~/Desktop/java-demo.html`

`churn_vs_complexity --ruby --summary -m my_ruby_project >> ~/Desktop/monthly-report.txt`

`churn_vs_complexity --java -m --since 2019-03-01 --timetravel 30 --graph my_java_project > ~/Desktop/timetravel-after-1st-march-2019.html`

`churn_vs_complexity --delta 1496402e81e68e86c5ac240559099fbe581a9a2g --delta 2845296758861773778d70d96328a5f2a1a9e933  --js --summary my_javascript_project > ~/Desktop/interesting-commits.txt`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/beatmadsen/churn_vs_complexity.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
