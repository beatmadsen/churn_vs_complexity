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

        changes.each do |change|
          change[:full_path] = File.join(worktree.folder, change[:path])
        end

        files = changes.reject { |change| change[:type] == :deleted }.map { |change| change[:full_path] }

        engine = @factory.engine(language: @language, excluded: @excluded, files:)

        values_by_file = engine.check(folder: worktree.folder)[:values_by_file]

        changes.each do |annotated_file|
          annotated_file[:complexity] = values_by_file.dig(annotated_file[:full_path], 1)
        end

        result = commit_summary(worktree_folder: worktree.folder)
        result[:changes] = changes

        @serializer.serialize(result)
      end

      private

      def commit_summary(worktree_folder:)
        summary = { commit: @commit }
        if @serializer.respond_to?(:has_commit_summary?) && @serializer.has_commit_summary?
          parent, next_commit = @factory.git_strategy(folder: worktree_folder).surrounding(commit: @commit)
          summary.merge!(parent:, next_commit:)
        end
        summary
      end

      def valid_commit?(folder:)
        @factory.git_strategy(folder:).valid_commit?(commit: @commit)
      end
    end
  end
end
