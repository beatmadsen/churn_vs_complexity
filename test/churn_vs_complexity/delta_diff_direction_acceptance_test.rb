# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class DeltaDiffDirectionAcceptanceTest < TLDR
    # Commit dfda965 added CLAUDE.md (among other files).
    # With the bug, added files show as :deleted because the diff direction is reversed.
    COMMIT_THAT_ADDED_FILES = 'dfda9657dd0c39fc3db26995c50038912558ce8b'
    KNOWN_ADDED_FILE = 'CLAUDE.md'

    def test_should_report_added_files_as_new_not_deleted
      # Given: a commit that added CLAUDE.md to the repository
      git = GitStrategy.new(folder: ROOT_PATH)

      # When: we get the changes for that commit
      changes = git.changes(commit: COMMIT_THAT_ADDED_FILES)

      # Then: CLAUDE.md should appear as :new (added), not :deleted
      claude_md_change = changes.find { |c| c[:path] == KNOWN_ADDED_FILE }
      refute_nil claude_md_change,
                 "Expected #{KNOWN_ADDED_FILE} in changes for commit #{COMMIT_THAT_ADDED_FILES}"
      assert_equal :new, claude_md_change[:type],
                   "#{KNOWN_ADDED_FILE} was added in this commit, so type should be :new, not :#{claude_md_change[:type]}"
    end

    def test_should_handle_initial_commit_without_error
      # Given: the very first commit in the repo (no parent)
      git = GitStrategy.new(folder: ROOT_PATH)
      first_commit = `git -C #{ROOT_PATH} rev-list --max-parents=0 HEAD`.chomp

      # When: we get changes for the initial commit
      changes = git.changes(commit: first_commit)

      # Then: all files should be :new (everything was added)
      assert changes.any?, 'Initial commit should have changes'
      changes.each do |change|
        assert_equal :new, change[:type],
                     "#{change[:path]} in initial commit should be :new, got :#{change[:type]}"
      end
    end
  end
end
