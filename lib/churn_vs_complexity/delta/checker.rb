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
        raise Error, 'Invalid commit' unless valid_commit?(folder:)

        git_strategy = @factory.git_strategy(folder:)
        changes = git_strategy.changes(commit: @commit)
        return [] if changes.empty?

        worktree = @factory.worktree(root_folder: folder, git_strategy:)
        worktree.prepare
        worktree.checkout(sha: @commit)

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
