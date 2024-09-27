# frozen_string_literal: true

require 'date'
require 'time'
require 'optparse'

module ChurnVsComplexity
  class CLI
    def self.run!
      # Create an options hash to store parsed options
      options = { excluded: [] }

      # Initialize OptionParser
      OptionParser.new do |opts|
        opts.banner = 'Usage: churn_vs_complexity [options] folder'

        opts.on('--java', 'Check complexity of java classes') do
          options[:language] = :java
        end

        opts.on('--ruby', 'Check complexity of ruby files') do
          options[:language] = :ruby
        end

        opts.on('--js', '--ts', '--javascript', '--typescript', 'Check complexity of javascript and typescript files') do
          options[:language] = :javascript
        end

        opts.on('--csv', 'Format output as CSV') do
          options[:serializer] = :csv
        end

        opts.on('--graph', 'Format output as HTML page with Churn vs Complexity graph') do
          options[:serializer] = :graph
        end

        opts.on('--summary', 'Output summary statistics (mean and median) for churn and complexity') do
          options[:serializer] = :summary
        end

        opts.on('--excluded PATTERN',
                'Exclude file paths including this string. Can be used multiple times.',) do |value|
          options[:excluded] << value
        end

        opts.on('--since YYYY-MM-DD', 'Calculate churn after this date') do |value|
          options[:since] = value
        end

        opts.on('-m', '--month', 'Calculate churn for the month leading up to the most recent commit') do
          options[:since] = :month
        end

        opts.on('-q', '--quarter', 'Calculate churn for the quarter leading up to the most recent commit') do
          options[:since] = :quarter
        end

        opts.on('-y', '--year', 'Calculate churn for the year leading up to the most recent commit') do
          options[:since] = :year
        end

        opts.on('--timetravel N', 'Calculate summary for all commits at intervals of N days throughout project history') do |value|
          options[:mode] = :timetravel
          options[:jump_days] = value.to_i
        end

        opts.on('--dry-run', 'Echo the chosen options from the CLI') do
          puts options
          exit
        end

        opts.on('-h', '--help', 'Display help') do
          puts opts
          exit
        end
      end.parse!

      # First argument that is not an option is the folder
      folder = ARGV.first

      raise Error, 'No folder selected. Use --help for usage information.' if folder.nil? || folder.empty?

      #  Verify that folder exists
      raise Error, "Folder #{folder} does not exist" unless File.directory?(folder)

      raise Error, 'No options selected. Use --help for usage information.' if options.empty?

      config = Config.new(**options)

      config.validate!

      if options[:mode] == :timetravel
        puts config.timetravel.go(folder:)
      else
        puts config.to_engine.check(folder:)
      end
    end
  end
end
