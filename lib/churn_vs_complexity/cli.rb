# frozen_string_literal: true

require_relative 'cli/parser'

module ChurnVsComplexity
  module CLI
    class << self
      def run!
        parser, options = Parser.create
        parser.parse!
        # First argument that is not an option is the folder
        folder = ARGV.first

        validate_folder!(folder)
        validate_options!(options)
        config = config(options)
        config.validate!
        puts config.checker.check(folder:)
      end

      private

      def validate_folder!(folder)
        raise Error, 'No folder selected. Use --help for usage information.' if folder.nil? || folder.empty?
        raise Error, "Folder #{folder} does not exist" unless File.directory?(folder)
      end

      def validate_options!(options)
        raise Error, 'No options selected. Use --help for usage information.' if options.empty?
        raise Error, 'No language selected. Use --help for usage information.' if options[:language].nil?
        raise Error, 'No serializer selected. Use --help for usage information.' if options[:serializer].nil?
      end

      def config(options)
        config_class = case options[:mode]
                       when :timetravel then Timetravel::Config
                       when :delta then Delta::Config
                       else Normal::Config
                       end
        config_class.new(**options)
      end
    end
  end
end
