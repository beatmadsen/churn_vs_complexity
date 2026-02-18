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

    def test_should_report_added_files_as_type_new
      # Given: commit dfda965 added CLAUDE.md
      git = GitStrategy.new(folder: ROOT_PATH)

      # When: we get the changes for that commit
      changes = git.changes(commit: 'dfda965')

      # Then: CLAUDE.md should be :new (it was added in this commit)
      claude_change = changes.find { |c| c[:path] == 'CLAUDE.md' }
      assert_equal :new, claude_change[:type],
                   'Added file should have type :new, not :deleted (diff direction must be parent→commit)'
    end

    def test_should_report_initial_commit_files_as_type_new
      # Given: the very first commit in the repo (no parent)
      git = GitStrategy.new(folder: ROOT_PATH)
      first_commit = `git -C #{ROOT_PATH} rev-list --max-parents=0 HEAD`.chomp

      # When: we get changes for the initial commit
      changes = git.changes(commit: first_commit)

      # Then: all files should be :new (everything was added from nothing)
      assert changes.any?, 'Initial commit should have changes'
      non_new = changes.reject { |c| c[:type] == :new }
      assert_empty non_new,
                   "All initial commit files should be :new, but found: #{non_new.map { |c| "#{c[:path]}=#{c[:type]}" }.join(', ')}"
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
