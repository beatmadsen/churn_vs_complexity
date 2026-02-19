# frozen_string_literal: true

require 'optparse'

module ChurnVsComplexity
  module CLI
    module Parser
      def self.create
        options = { excluded: [] }
        parser = OptionParser.new do |opts|
          opts.banner = 'Usage: churn_vs_complexity [options] folder|file...'

          opts.separator ''
          opts.separator 'Languages:'

          opts.on('--java', 'Check complexity of java classes') do
            options[:language] = :java
          end

          opts.on('--ruby', 'Check complexity of ruby files') do
            options[:language] = :ruby
          end

          opts.on('--js', '--ts', '--javascript', '--typescript',
                  'Check complexity of javascript and typescript files',) do
            options[:language] = :javascript
          end

          opts.on('--python', 'Check complexity of python files') do
            options[:language] = :python
          end

          opts.on('--go', 'Check complexity of go files') do
            options[:language] = :go
          end

          opts.separator ''
          opts.separator 'Modes (mutually exclusive):'

          opts.on('--timetravel N',
                  'Calculate summary for all commits at intervals of N days throughout project history or from the date specified with --since',) do |value|
            options[:mode] = :timetravel
            options[:jump_days] = value.to_i
          end

          opts.on('--triage',
                  'Assess risk of files based on churn and complexity. Accepts file paths or a folder as arguments.',) do
            options[:mode] = :triage
          end

          opts.on('--hotspots', 'Generate ranked list of files by risk') do
            options[:mode] = :hotspots
          end

          opts.on('--gate',
                  'Pass/fail quality check against gamma threshold (exits 0 on pass, 1 on fail)',) do
            options[:mode] = :gate
          end

          opts.on('--focus start|end',
                  'Capture complexity snapshot before (start) and after (end) a coding session',) do |value|
            options[:mode] = :focus
            options[:subcommand] = value.to_sym
          end

          opts.on('--diff REF', 'Compare codebase health between REF and HEAD') do |value|
            options[:mode] = :diff
            options[:reference] = value
          end

          opts.on('--delta SHA',
                  'Identify changes between the specified commit (SHA) and the previous commit and annotate changed files with complexity score. SHA can be a full or short commit hash, or the value HEAD. Can be used multiple times to specify multiple commits.',) do |value|
            options[:mode] = :delta
            (options[:commits] ||= []) << value
          end

          opts.separator ''
          opts.separator 'Output formats:'

          opts.on('--csv', 'Format output as CSV') do
            options[:serializer] = :csv
          end

          opts.on('--graph', 'Format output as HTML page with Churn vs Complexity graph') do
            options[:serializer] = :graph
          end

          opts.on('--summary', 'Output summary statistics (mean and median) for churn and complexity') do
            options[:serializer] = :summary
          end

          opts.on('--json', 'Format output as JSON') do
            options[:serializer] = :json
          end

          opts.on('--markdown', 'Format output as Markdown') do
            options[:serializer] = :markdown
          end

          opts.separator ''
          opts.separator 'Modifiers:'

          opts.on('--excluded PATTERN',
                  'Exclude file paths including this string. Can be used multiple times.',) do |value|
            options[:excluded] << value
          end

          opts.on('--since YYYY-MM-DD',
                  'Normal mode: Calculate churn after this date. Timetravel mode: calculate summaries from this date',) do |value|
            options[:since] = value
          end

          opts.on('-m', '--month', 'Calculate churn for the month leading up to the most recent commit') do
            options[:relative_period] = :month
          end

          opts.on('-q', '--quarter', 'Calculate churn for the quarter leading up to the most recent commit') do
            options[:relative_period] = :quarter
          end

          opts.on('-y', '--year', 'Calculate churn for the year leading up to the most recent commit') do
            options[:relative_period] = :year
          end

          opts.on('--max-gamma N', Float, 'Maximum gamma score threshold for gate mode (default: 25)') do |value|
            options[:max_gamma] = value
          end

          opts.on('--dry-run', 'Echo the chosen options from the CLI') do
            puts options
            exit
          end

          opts.on('-h', '--help', 'Display help') do
            puts opts
            exit
          end

          opts.on('--version', 'Display version') do
            puts ChurnVsComplexity::VERSION
            exit
          end
        end
        [parser, options]
      end
    end
  end
end
