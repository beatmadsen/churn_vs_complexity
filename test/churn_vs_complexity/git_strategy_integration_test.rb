# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class GitStrategyIntegrationTest < TLDR

    def test_that_it_can_get_changes_for_the_first_commit
      g = GitStrategy.new(folder: ROOT_PATH)
      repo = Git.open(ROOT_PATH)

      first_commit = repo.log(max_count = 100_000).last.sha

      changes = g.changes(commit: first_commit)
      assert changes.any?, "No changes found for first commit #{first_commit}"
    end

    def test_that_it_can_get_changes_for_the_last_commit
      g = GitStrategy.new(folder: ROOT_PATH)
      repo = Git.open(ROOT_PATH)

      last_commit = repo.log.first.sha

      changes = g.changes(commit: last_commit)
      assert changes.any?, "No changes found for last commit #{last_commit}"
    end
  end
end
