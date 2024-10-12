# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class Checker
      def initialize(serializer:, factory:, commit:, language:, excluded:, data_isolation_id: 0)
        @serializer = serializer
        @excluded = excluded
        @factory = factory
        @commit = commit
        @language = language
        @data_isolation_id = data_isolation_id        
      end

      def check(folder:)
        raise Error, 'Invalid commit' unless valid_commit?(folder:)

        git_strategy = @factory.git_strategy(folder:)
        changes = git_strategy.changes(commit: @commit)
        return [] if changes.empty?

        worktree = @factory.worktree(root_folder: folder, git_strategy:, data_isolation_id: @data_isolation_id)
        worktree.prepare
        worktree.checkout(sha: @commit)

        files = changes.map { |change| change[:path] }
        # we need to create engine here becuase it needs to have a file selector that only selects files that are changed
        engine = @factory.engine(language: @language, excluded: @excluded, files:)
        complexity_result = engine.check(folder:)[:values_by_file]

        changes.map do |annotated_file|

          'process me'
        end
      end

      private

      def valid_commit?(folder:)
        @factory.git_strategy(folder:).valid_commit?(commit: @commit)
      end
    end
  end
end
