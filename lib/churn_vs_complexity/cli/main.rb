# frozen_string_literal: true

require 'optparse'

module ChurnVsComplexity
  module CLI
    module Main
      class << self
        def run!(options, folder)
          validate_folder!(folder)
          validate_options!(options)
          config = config(options)
          config.validate!

          config.checker.check(folder:)
        end

        private

        def validate_folder!(folder)
          raise ValidationError, 'No folder selected. Use --help for usage information.' if folder.nil? || folder.empty?
          raise ValidationError, "Folder #{folder} does not exist" unless File.directory?(folder)
        end

        def validate_options!(options)
          raise ValidationError, 'No options selected. Use --help for usage information.' if options.empty?
          raise ValidationError, 'No language selected. Use --help for usage information.' if options[:language].nil?

          return unless options[:serializer].nil?

          raise ValidationError, 'No serializer selected. Use --help for usage information.'
        end

        def config(options)
          config_class =
            case options[:mode]
            when :timetravel then Timetravel::Config
            when :delta then Delta::Config
            else Normal::Config
            end
          config_class.new(**options)
        end
      end
    end
  end
end
