# frozen_string_literal: true

require 'date'
require 'time'
require 'optparse'

module ChurnVsComplexity
  class CLI
    def self.run!
      # Create an options hash to store parsed options
      options = { excluded: [] }
      since = nil

      # Initialize OptionParser
      OptionParser.new do |opts|
        opts.banner = 'Usage: churn_vs_complexity [options] folder'

        opts.on('--java', 'Check complexity of java classes') do
          options[:language] = :java
        end

        opts.on('--ruby', 'Check complexity of ruby files') do
          options[:language] = :ruby
        end

        opts.on('--csv', 'Format output as CSV') do
          options[:serializer] = :csv
        end

        opts.on('--graph', 'Format output as HTML page with Churn vs Complexity graph') do
          options[:serializer] = :graph
        end

        opts.on('--excluded PATTERN',
                'Exclude file paths including this string. Can be used multiple times.',) do |value|
          options[:excluded] << value
        end

        opts.on('--since YYYY-MM-DD', 'Calculate churn after this date') do |value|
          since = value
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

      begin
        if since.nil?
          since = Time.at(0).to_date
          options[:graph_title] = 'Churn vs Complexity'
        else
          date_string = since
          since = Date.strptime(since, '%Y-%m-%d')
          options[:graph_title] = "Churn vs Complexity since #{date_string}"
        end
      rescue StandardError
        raise Error, "Invalid date #{since}, please use correct format, YYYY-MM-DD"
      end

      config = Config.new(**options)

      config.validate!

      puts config.to_engine.check(folder:, since:)
    end
  end
end
