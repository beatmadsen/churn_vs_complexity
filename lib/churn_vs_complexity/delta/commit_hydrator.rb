# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class CommitHydrator
      def initialize(git_strategy:, serializer:)
        @git_strategy = git_strategy
        @serializer = serializer
      end

      def hydrate(commit_sha)
        commit = @git_strategy.object(commit_sha)
        summary = { commit: commit.sha }
        if @serializer.respond_to?(:has_commit_summary?) && @serializer.has_commit_summary?
          parent, next_commit = @git_strategy.surrounding(commit:)
          summary.merge!(parent:, next_commit:)
        end
        summary
      end
    end
  end
end
