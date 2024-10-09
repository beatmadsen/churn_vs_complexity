# frozen_string_literal: true

require 'test_helper'
module ChurnVsComplexity
  module Timetravel
    class WorktreeIntegrationTest < TLDR
      def test_worktree_switching
        git_strategy = GitStrategy.new(folder: PROJECT_ROOT_FOLDER)
        worktree = Worktree.new(root_folder: PROJECT_ROOT_FOLDER, git_strategy:, number: 42)
        worktree.prepare
        worktree.checkout('81845d632a4ceca8935d39a204b054f09512088e')

        #  chech that project root is still at the latest commit
        repo = Git.open(PROJECT_ROOT_FOLDER)
        current_sha = repo.object('HEAD').sha
        refute_equal '81845d632a4ceca8935d39a204b054f09512088e', current_sha,
                     'Project root should not be at the checked out commit'

        # Verify that the worktree is at the correct commit
        worktree_repo = Git.open(worktree.folder)
        worktree_sha = worktree_repo.object('HEAD').sha
        assert_equal '81845d632a4ceca8935d39a204b054f09512088e', worktree_sha,
                     'Worktree should be at the checked out commit'
      end

      def test_concurrent_worktree_switching
        git_strategy = GitStrategy.new(folder: PROJECT_ROOT_FOLDER)

        pipes = [[1664, '81845d632a4ceca8935d39a204b054f09512088e'],
                 [1665, 'b184ad0dcfab525242b18f8de6e792be083b861c'],].map do |(number, sha)|
          worktree = Worktree.new(root_folder: PROJECT_ROOT_FOLDER, git_strategy:, number:)
          worktree.prepare
          pipe = IO.pipe
          fork do
            worktree.checkout(sha)
            worktree_repo = Git.open(worktree.folder)
            worktree_sha = worktree_repo.object('HEAD').sha
            pipe[1].puts(worktree_sha)
            pipe[1].close
          end

          pipe
        end

        shas = pipes.map do |pipe|
          sha = pipe[0].gets.chomp
          pipe.each(&:close)
          sha
        end

        assert_equal %w[81845d632a4ceca8935d39a204b054f09512088e b184ad0dcfab525242b18f8de6e792be083b861c].sort,
                     shas.sort
        # check that project root is still at the latest commit
        repo = Git.open(PROJECT_ROOT_FOLDER)
        current_sha = repo.object('HEAD').sha
        refute_equal '81845d632a4ceca8935d39a204b054f09512088e', current_sha,
                     'Project root should not be at the checked out commit'
        refute_equal 'b184ad0dcfab525242b18f8de6e792be083b861c', current_sha,
                     'Project root should not be at the checked out commit'
      end
    end
  end
end
