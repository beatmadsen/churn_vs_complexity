# frozen_string_literal: true

module ChurnVsComplexity
  module Gate
    class Config
      DEFAULT_MAX_GAMMA = 25

      def initialize(
        language:,
        serializer: :json,
        max_gamma: DEFAULT_MAX_GAMMA,
        since: nil,
        excluded: [],
        complexity_validator: ComplexityValidator,
        since_validator: Normal::SinceValidator,
        **options
      )
        @language = language
        @serializer = serializer
        @max_gamma = max_gamma
        @since = since
        @excluded = excluded
        @complexity_validator = complexity_validator
        @since_validator = since_validator
        @options = options
      end

      def validate!
        LanguageValidator.validate!(@language)
        @since_validator.validate!(since: @since, relative_period: nil)
        @complexity_validator.validate!(@language)
      end

      def checker
        normal_config = Normal::Config.new(
          language: @language,
          serializer: :none,
          since: @since,
          excluded: @excluded,
        )
        Checker.new(engine: normal_config.checker, serializer: gate_serializer, max_gamma: @max_gamma)
      end

      private

      def gate_serializer
        case @serializer
        when :json then Serializer::Json
        end
      end
    end
  end
end
