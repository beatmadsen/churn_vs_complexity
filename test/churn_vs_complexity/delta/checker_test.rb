# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Delta
    DEFAULT_COMMIT = 'abc123ee'
    DEFAULT_CHANGES = [{ path: 'file1', type: :modified }, { path: 'file2', type: :deleted }].freeze

    class CheckerTest < TLDR
      # Idea for check algorithm:
      # 1. Find commit in log
      # 2. Find all files changed in this commit
      # 3. Annotate changed files with type of change (create, delete, modify)
      # 4. Validate changed files with complexity validator
      # 5. Serialize results

      def test_that_it_fails_when_commit_is_not_found_in_log
        g = git_strategy(valid_commits: [])
        f = factory(git_strategy: g)
        assert_raises(StandardError) do
          checker(factory: f).check(folder: 'space-place')
        end
      end

      def test_that_it_returns_empty_array_when_no_files_are_changed
        g = git_strategy(changes: [])
        f = factory(git_strategy: g)
        assert_equal [], checker(factory: f).check(folder: 'space-place')
      end

      def test_that_it_fails_when_it_cannot_prepare_a_worktree_and_there_are_changes
        f = factory(worktree: worktree(fail_to_prepare: true))
        # TODO: move worktree up one level
        assert_raises(Timetravel::Worktree::Error) do
          checker(factory: f).check(folder: 'space-place')
        end
      end

      def test_that_it_fails_when_it_cannot_calculate_complexity_for_a_file
        f = factory(engine: engine(fail_to_process: true))
        # TODO: wire Engine for custom complexity calculator
        assert_raises(Error) do
          checker(factory: f).check(folder: 'space-place')
        end
      end

      private

      def checker(factory: FactoryStub.new, serializer: Normal::Serializer::None, excluded: [], commit: DEFAULT_COMMIT, 
language: :ruby)
        Checker.new(factory:, serializer:, excluded:, commit:, language:)
      end

      def factory(git_strategy: git_strategy, worktree: worktree, engine: engine)
        FactoryStub.new(git_strategy:, worktree:, engine:)
      end

      def git_strategy(valid_commits: [DEFAULT_COMMIT], changes: DEFAULT_CHANGES)
        GitStrategyStub.new(valid_commits:, changes:)
      end

      def worktree(fail_to_prepare: false, fail_to_checkout: false)
        WorktreeStub.new(fail_to_prepare:, fail_to_checkout:)
      end

      def engine(fail_to_process: false)
        EngineStub.new(fail_to_process:)
      end
    end

    class FactoryStub
      delegate :complexity_validator, to: Factory

      def initialize(git_strategy:, worktree:, engine:)
        @git_strategy = git_strategy
        @worktree = worktree
        @engine = engine
      end

      def git_strategy(*) = @git_strategy

      def worktree(*) = @worktree
      def engine(*) = @engine
    end

    class GitStrategyStub
      def initialize(valid_commits:, changes:)
        @valid_commits = valid_commits
        @changes = changes
      end

      def valid_commit?(commit:)
        @valid_commits.include?(commit)
      end

      def changes(commit:)
        @changes
      end
    end

    class WorktreeStub
      def initialize(fail_to_prepare:, fail_to_checkout:)
        @fail_to_prepare = fail_to_prepare
        @fail_to_checkout = fail_to_checkout
      end

      def prepare
        raise Timetravel::Worktree::Error, 'Failed to prepare worktree' if @fail_to_prepare
      end

      def checkout(sha:)
        raise Timetravel::Worktree::Error, "Failed to checkout #{sha} in worktree" if @fail_to_checkout
      end
    end

    class EngineStub
      def initialize(fail_to_process: false)
        @fail_to_process = fail_to_process
      end

      def check(*)
        raise Error, 'Failed to process files' if @fail_to_process

        { values_by_file: {} }
      end
    end
  end
end
