# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Delta
    DEFAULT_COMMIT = 'abc123ee'
    DEFAULT_CHANGES = [{ path: 'file1.rb', type: :modified }, { path: 'file2.rb', type: :deleted }].freeze

    class CheckerTest < TLDR
      def test_that_it_fails_when_commit_is_not_found_in_log
        g = Stubs.create_git_strategy(valid_commits: [])
        f = Stubs.create_factory(git_strategy: g)
        assert_raises(StandardError) do
          create_checker(factory: f).check(folder: 'space-place')
        end
      end

      def test_that_it_returns_commit_summary_only_when_no_files_are_changed
        g = Stubs.create_git_strategy(changes: [])
        f = Stubs.create_factory(git_strategy: g)
        assert_equal({ commit: 'abc123ee' }, create_checker(factory: f).check(folder: 'space-place'))
      end

      def test_that_it_fails_when_it_cannot_prepare_a_worktree_and_there_are_changes
        f = Stubs.create_factory(worktree: Stubs.create_worktree(fail_to_prepare: true))
        # TODO: move worktree up one level
        assert_raises(Timetravel::Worktree::Error) do
          create_checker(factory: f).check(folder: 'space-place')
        end
      end

      def test_that_it_fails_when_it_cannot_calculate_complexity_for_a_file
        f = Stubs.create_factory(engine: Stubs.create_engine(fail_to_process: true))
        assert_raises(Error) do
          create_checker(factory: f).check(folder: 'space-place')
        end
      end

      def test_that_engine_files_base_folder_is_worktree_folder
        f = FactoryMock.new
        create_checker(factory: f).check(folder: 'some-root-folder')

        files = f.engine_called_with[:files]
        files.each do |file|
          assert file.start_with?(WorktreeStub::FOLDER), "File #{file} is not prefixed with #{WorktreeStub::FOLDER}"
        end
      end

      def test_that_changed_files_with_irrelevant_extensions_are_ignored
        result = create_checker(language: :javascript).check(folder: 'space-place')
        expected = { commit: 'abc123ee', changes: [] }
        assert_equal expected, result
      end

      def test_that_it_succeeds_when_all_is_good
        result = create_checker.check(folder: 'space-place')
        expected = { commit: 'abc123ee',
                     changes: [{ path: 'file1.rb', type: :modified, full_path: 'my-worktree/file1.rb', complexity: 3 },
                               { path: 'file2.rb', type: :deleted, full_path: 'my-worktree/file2.rb',
                                 complexity: 2, },], }
        assert_equal expected, result
      end

      def test_that_it_includes_surrounding_commits_when_serializer_supports_it
        result = create_checker(serializer: Serializer::PassThrough).check(folder: 'space-place')
        expected = { commit: 'abc123ee', parent: 'aabbccdd', next_commit: 'bbbbccdd',
                     changes: [{ path: 'file1.rb', type: :modified, full_path: 'my-worktree/file1.rb', complexity: 3 },
                               { path: 'file2.rb', type: :deleted, full_path: 'my-worktree/file2.rb',
                                 complexity: 2, },], }
        assert_equal expected, result
      end

      private

      def create_checker(factory: Stubs.create_factory, serializer: Normal::Serializer::None, excluded: [], commit: DEFAULT_COMMIT,
                         language: :ruby)
        Checker.new(factory:, serializer:, excluded:, commit:, language:)
      end
    end

    module Stubs
      class << self
        def create_factory(git_strategy: create_git_strategy, worktree: create_worktree, engine: create_engine)
          FactoryStub.new(git_strategy:, worktree:, engine:)
        end

        def create_git_strategy(valid_commits: [DEFAULT_COMMIT], changes: DEFAULT_CHANGES.map(&:dup))
          GitStrategyStub.new(valid_commits:, changes:)
        end

        def create_worktree(fail_to_prepare: false, fail_to_checkout: false)
          WorktreeStub.new(fail_to_prepare:, fail_to_checkout:)
        end

        def create_engine(fail_to_process: false)
          EngineStub.new(fail_to_process:)
        end
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

    class FactoryMock
      attr_reader :engine_called_with, :stub

      delegate :git_strategy, :worktree, to: :stub

      def initialize
        @stub = Stubs.create_factory
      end

      def engine(**options)
        @engine_called_with = options
        stub.engine(**options)
      end
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

      def surrounding(commit:)
        %w[aabbccdd bbbbccdd]
      end
    end

    class WorktreeStub
      FOLDER = 'my-worktree'

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

      def folder = FOLDER
    end

    class EngineStub
      def initialize(fail_to_process: false)
        @fail_to_process = fail_to_process
      end

      def check(*)
        raise Error, 'Failed to process files' if @fail_to_process

        base_folder = WorktreeStub::FOLDER

        { values_by_file: { File.join(base_folder, 'file1.rb') => [0, 3],
                            File.join(base_folder, 'file2.rb') => [0, 2], } }
      end
    end
  end
end
