# frozen_string_literal: true

module ChurnVsComplexity
  module Timetravel
    module Factory
      def self.git_strategy(folder:) = GitStrategy.new(folder:)
      def self.pipe = IO.pipe
      def self.worker(engine:, worktree:) = Worker.new(engine:, worktree:)
      def self.worktree(root_folder:, git_strategy:, number:) = Worktree.new(root_folder:, git_strategy:, number:)
    end
  end
end
