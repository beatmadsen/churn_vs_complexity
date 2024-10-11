# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class Config
      def initialize(
        language:,
        serializer:,
        commit:, 
        excluded: [],
        complexity_validator: ComplexityValidator,
        factory: Factory,
        **_options
      )
        @language = language
        @serializer = serializer
        @excluded = excluded
        @commit = commit
        @factory = factory
      end

      def validate!
        validate_commit!
        LanguageValidator.validate!(@language)
        SerializerValidator.validate!(serializer: @serializer)
        @factory.complexity_validator.validate!(@language)
      end

      def checker = Checker.new(serializer:, excluded: @excluded, factory: @factory)

      private

      def validate_commit!
        return if @commit.match?(/\A[0-9a-f]{40}\z/i) || @commit.match?(/\A[0-9a-f]{8}\z/i)

        raise ValidationError,
              "Invalid commit: #{@commit}. It must be a valid 40-character SHA-1 hash or an 8-character shortened form."
      end

      def serializer = Serializer.resolve(@serializer)
        
    end
  end
end
