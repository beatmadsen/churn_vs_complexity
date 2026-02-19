# frozen_string_literal: true

module ChurnVsComplexity
  module Focus
    class Config
      DEFAULT_BASELINE_PATH = '.focus-baseline.json'

      def initialize(
        language:,
        subcommand:,
        serializer: :json,
        since: nil,
        excluded: [],
        baseline_path: DEFAULT_BASELINE_PATH,
        complexity_validator: ComplexityValidator,
        since_validator: Normal::SinceValidator,
        **options
      )
        @language = language
        @subcommand = subcommand.to_sym
        @serializer = serializer
        @since = since
        @excluded = excluded
        @baseline_path = baseline_path
        @complexity_validator = complexity_validator
        @since_validator = since_validator
        @options = options
      end

      def validate!
        LanguageValidator.validate!(@language)
        @since_validator.validate!(since: @since, relative_period: nil)
        @complexity_validator.validate!(@language)
        validate_subcommand!
      end

      def checker
        Checker.new(
          engine: normal_engine,
          subcommand: @subcommand,
          serializer: focus_serializer,
          baseline_path: @baseline_path,
        )
      end

      private

      def normal_engine
        Normal::Config.new(language: @language, serializer: :none, since: @since, excluded: @excluded).checker
      end

      def validate_subcommand!
        return if %i[start end].include?(@subcommand)

        raise ValidationError, "Invalid focus subcommand: #{@subcommand}. Use 'start' or 'end'."
      end

      def focus_serializer
        case @subcommand
        when :start then nil # start doesn't need a serializer
        when :end then Serializer::Json
        end
      end
    end
  end
end
