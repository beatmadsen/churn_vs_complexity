# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class Config
      def initialize(
        language:,
        serializer:,
        excluded: [],
        complexity_validator: ComplexityValidator,
        since_validator: SinceValidator,
        **options
      )
        @language = language
        @serializer = serializer
        @excluded = excluded
        @complexity_validator = complexity_validator
        @since_validator = since_validator
      end

      def validate!
        LanguageValidator.validate!(@language)
        SerializerValidator.validate!(serializer: @serializer)
        @complexity_validator.validate!(@language)
      end

      def checker = Checker.new(serializer:)

      private

      def serializer
        case @serializer
        when :none
          Serializer::None
        when :csv
          Serializer::CSV
        when :summary
          Serializer::Summary
        end
      end
    end
  end
end
