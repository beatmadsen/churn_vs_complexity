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

        worktree = setup_worktree(folder:)

        changes = @factory.git_strategy(folder: worktree.folder).changes(commit: @commit)
        result = commit_summary(folder:)
        unless changes.empty?
          ComplexityAnnotator.new(factory: @factory, changes:)
                             .enhance(worktree_folder: worktree.folder, language: @language, excluded: @excluded, commit: @commit)
          result[:changes] = changes
        end

        @serializer.serialize(result)
      end

      private

      def setup_worktree(folder:)
        worktree = @factory.worktree(root_folder: folder, git_strategy: @factory.git_strategy(folder:),
                                     data_isolation_id: @data_isolation_id,)
        worktree.prepare
        worktree.checkout(@commit)

        worktree
      end

      def commit_summary(folder:)
        CommitHydrator.new(
          git_strategy: @factory.git_strategy(folder:),
          serializer: @serializer,
        ).hydrate(@commit)
      end

      def valid_commit?(folder:)
        @factory.git_strategy(folder:).valid_commit?(commit: @commit)
      end
    end
  end
end
