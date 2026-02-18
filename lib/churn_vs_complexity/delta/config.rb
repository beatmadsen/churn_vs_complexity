# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class Config
      def initialize(
        language:,
        serializer:,
        commits:,
        excluded: [],
        complexity_validator: ComplexityValidator,
        factory: Factory,
        **_options
      )
        @language = language
        @serializer = serializer
        @excluded = excluded
        @commits = commits
        @factory = factory
      end

      def validate!
        validate_commits!
        LanguageValidator.validate!(@language)
        SerializerValidator.validate!(serializer: @serializer)
        @factory.complexity_validator.validate!(@language)
      end

      def checker
        MultiChecker.new(serializer:, excluded: @excluded, factory: @factory, commits: @commits,
                         language: @language,)
      end

      private

      def validate_commits!
        @commits.each { |commit| validate_commit!(commit) }
      end

      def validate_commit!(commit)
        return if commit == 'HEAD' || commit.match?(/\A[0-9a-f]{40}\z/i) || commit.match?(/\A[0-9a-f]{7,12}\z/i)

        raise ValidationError,
              "Invalid commit: #{commit}. It must be a valid 40-character SHA-1 hash or a 7-12 character shortened form."
      end

      def serializer = Serializer.resolve(@serializer)
    end
  end
end
