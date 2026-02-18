# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class GitStrategyIntegrationTest < TLDR
    def test_that_it_can_get_changes_for_the_first_commit
      g = GitStrategy.new(folder: ROOT_PATH)

      first_commit = `git -C #{ROOT_PATH} rev-list --max-parents=0 HEAD`.chomp

      changes = g.changes(commit: first_commit)
      assert changes.any?, "No changes found for first commit #{first_commit}"
    end

    def test_that_it_can_get_changes_for_the_last_commit
      g = GitStrategy.new(folder: ROOT_PATH)

      last_commit = `git -C #{ROOT_PATH} rev-parse HEAD`.chomp

      changes = g.changes(commit: last_commit)
      assert changes.any?, "No changes found for last commit #{last_commit}"
    end

    def test_that_it_can_get_surrounding_commits
      g = GitStrategy.new(folder: ROOT_PATH)

      next_commit, middle, parent = `git -C #{ROOT_PATH} log -3 --format=%H`.lines.map(&:chomp)

      surrounding = g.surrounding(commit: middle)
      assert_equal [parent, next_commit], surrounding
    end

    def test_that_it_can_get_surrounding_commits_for_the_last_commit
      g = GitStrategy.new(folder: ROOT_PATH)

      middle, parent = `git -C #{ROOT_PATH} log -2 --format=%H`.lines.map(&:chomp)

      surrounding = g.surrounding(commit: middle)
      assert_equal [parent, nil], surrounding
    end
  end
end
