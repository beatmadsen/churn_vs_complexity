# frozen_string_literal: true

require_relative 'cli/parser'
require_relative 'cli/main'

module ChurnVsComplexity
  module CLI
    class << self
      def run!
        parser, options = Parser.create
        parser.parse!
        # First argument that is not an option is the folder
        folder = ARGV.first

        result = Main.run!(options, folder)
        puts result
        exit 1 if result.respond_to?(:passed?) && !result.passed?
      end
    end
  end
end
