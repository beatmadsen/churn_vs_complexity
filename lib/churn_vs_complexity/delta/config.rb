# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class Config
      def initialize(
        language:,
        serializer:,
        excluded: [],
        complexity_validator: ComplexityValidator,
        commit:,
        **_options
      )
        @language = language
        @serializer = serializer
        @excluded = excluded
        @complexity_validator = complexity_validator
        @commit = commit
      end

      def validate!
        # TODO: validate that commit exists.
        LanguageValidator.validate!(@language)
        SerializerValidator.validate!(serializer: @serializer)
        @complexity_validator.validate!(@language)
      end

      def checker = Checker.new(serializer:, excluded: @excluded)

      private

      def serializer
        case @serializer
        when :none
          Normal::Serializer::None
        when :csv
          Serializer::CSV
        when :summary
          Serializer::Summary
        end
      end
    end
  end
end
