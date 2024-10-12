# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    module Factory
      def self.complexity_validator = ComplexityValidator
      def self.git_strategy(folder:) = GitStrategy.new(folder:)
      def self.worktree(root_folder:, git_strategy:, data_isolation_id:) = Timetravel::Worktree.new(root_folder:, git_strategy:, number: 0, number: data_isolation_id)
      def self.engine(language:, excluded:, files:) = Delta.engine(language:, excluded:, files:)
    end
  end
end
