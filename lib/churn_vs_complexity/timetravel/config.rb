# frozen_string_literal: true

module ChurnVsComplexity
  module Timetravel
    class Config
      def initialize(
        language:,
        serializer:,
        excluded: [],
        since: nil,
        relative_period: nil,
        complexity_validator: ComplexityValidator,
        since_validator: SinceValidator,
        **options
      )
        @language = language
        @serializer = serializer
        @excluded = excluded
        @since = since
        @relative_period = relative_period
        @complexity_validator = complexity_validator
        @since_validator = since_validator
        @options = options
      end

      def validate!
        LanguageValidator.validate!(@language)

        SerializerValidator.validate!(serializer: @serializer)

        @since_validator.validate!(since: @since)
        RelativePeriodValidator.validate!(relative_period: @relative_period)
        @complexity_validator.validate!(@language)
      end

      def checker
        Traveller.new(
          since: @since,
          relative_period: @relative_period,
          engine: engine_config.checker,
          jump_days: @options[:jump_days],
          serializer: @serializer,
        )
      end

      private

      def engine_config
        Normal::Config.new(
          language: @language,
          serializer: :pass_through,
          excluded: @excluded,
          since: nil, # since has a different meaning in timetravel mode
          relative_period: @relative_period,
          complexity_validator: @complexity_validator,
          since_validator: @since_validator,
          **@options,
        )
      end
    end
  end
end
