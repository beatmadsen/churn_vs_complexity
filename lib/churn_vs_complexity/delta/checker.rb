# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class Checker
      def initialize(serializer:, excluded:, factory:, commit:)
        @serializer = serializer
        @excluded = excluded
        @factory = factory
        @commit = commit
      end

      def check(folder:)
        valid = @factory.git_strategy(folder:).valid_commit?(commit: @commit)
        raise Error, 'Invalid commit' unless valid

        'yo'
      end
    end
  end
end
