# ChurnVsComplexity

A tool to visualise code complexity in a project and help direct refactoring efforts.

Inspired by [Michael Feathers' article "Getting Empirical about Refactoring"](https://www.agileconnection.com/article/getting-empirical-about-refactoring) and the gem [turbulence](https://rubygems.org/gems/turbulence) by Chad Fowler and others.

This gem was built primarily to support analysis of Java and Ruby repositories, but it can easily be extended.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'churn_vs_complexity'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install churn_vs_complexity

This gem depends on git for churn analysis and [PMD](https://pmd.github.io) for complexity analysis of JVM based languages.

In order to use the `--java` flag, you must first install PMD manually, and the gem assumes it is available on the search path as `pmd`. On macOS, for example, you can install it using homebrew with `brew install pmd`.

## Usage

Execute the `churn_vs_complexity` with the applicable arguments. Output in the requested format will be directed to stdout.

```
churn_vs_complexity [options] folder
        --java                       Check complexity of java classes
        --ruby                       Check complexity of ruby files
        --csv                        Format output as CSV
        --graph                      Format output as HTML page with Churn vs Complexity graph
        --excluded PATTERN           Exclude file paths including this string. Can be used multiple times.
        --since YYYY-MM-DD           Calculate churn after this date
    -h, --help                       Display help
```

## Examples

`churn_vs_complexity --ruby --csv my_ruby_project > ~/Desktop/ruby-demo.csv`

`churn_vs_complexity --java --graph --exclude generated-sources --exclude generated-test-sources --since 2023-01-01 my_java_project > ~/Desktop/java-demo.html`



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/beatmadsen/churn_vs_complexity.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
