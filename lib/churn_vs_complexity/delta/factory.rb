# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    module Factory
      def self.complexity_validator = ComplexityValidator
      def self.git_strategy(folder:) = GitStrategy.new(folder:)

      def self.worktree(root_folder:, git_strategy:, data_isolation_id:)
        Timetravel::Worktree.new(
          root_folder:,
          git_strategy:,
          number: data_isolation_id,
        )
      end

      def self.engine(cache_components:, language:, excluded:, files:)
        Delta.engine(cache_components:, language:, excluded:, files:)
      end
    end
  end
end
