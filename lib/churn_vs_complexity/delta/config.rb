# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class Config
      def initialize(
        language:,
        serializer:,
        commit:, excluded: [],
        complexity_validator: ComplexityValidator,
        **_options
      )
        @language = language
        @serializer = serializer
        @excluded = excluded
        @complexity_validator = complexity_validator
        @commit = commit
      end

      def validate!
        validate_commit!
        LanguageValidator.validate!(@language)
        SerializerValidator.validate!(serializer: @serializer)
        @complexity_validator.validate!(@language)
      end

      def checker = Checker.new(serializer:, excluded: @excluded)

      private

      def validate_commit!
        unless @commit.match?(/\A[0-9a-f]{40}\z/i) || @commit.match?(/\A[0-9a-f]{8}\z/i)
          raise ValidationError, "Invalid commit: #{@commit}. It must be a valid 40-character SHA-1 hash or an 8-character shortened form."
        end
      end

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
