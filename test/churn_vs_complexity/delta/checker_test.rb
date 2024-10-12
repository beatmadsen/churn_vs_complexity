# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Delta
    DEFAULT_COMMIT = 'abc123ee'

    class CheckerTest < TLDR
      def test_check        
        result = checker(factory:).check(folder: 'space-place')
        assert_equal [], result
      end

      # Idea for check algorithm:
      # 1. Find commit in log
      # 2. Find all files changed in this commit
      #  3. Annotate changed files with type of change (create, delete, modify)
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

      private

      def checker(factory: FactoryStub.new, serializer: Normal::Serializer::None, excluded: [], commit: DEFAULT_COMMIT)
        Checker.new(factory:, serializer:, excluded:, commit:)
      end

      def factory(git_strategy: git_strategy())
        FactoryStub.new(git_strategy:)
      end

      def git_strategy(valid_commits: [DEFAULT_COMMIT], changes: [])
        GitStrategyStub.new(valid_commits:, changes:)
      end
    end

    class FactoryStub
      delegate :complexity_validator, to: Factory

      def initialize(git_strategy:)
        @git_strategy = git_strategy
      end

      def git_strategy(folder:) = @git_strategy
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
  end
end
