# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Timetravel
    class TravellerTest < TLDR
      def test_check
        git_strategy = GitStrategyStub.new(commits: %w[sha1 sha2])
        pipe_result = { 'a' => 2 }
        pipe = [as_io(pipe_result), StringIO.new]
        factory = FactoryStub.new(git_strategy:, pipe:)
        result = traveller(factory:).check(folder: 'space-place')
        assert_equal pipe_result, result
      end

      private

      def as_io(data)
        StringIO.new.tap do |io|
          JSON.dump(data, io)
          io.rewind
        end
      end

      def traveller(factory: FactoryStub.new, since: nil, relative_period: :month, jump_days: 3, engine: EngineStub,
                    serializer: :none)
        Traveller.new(factory:, since:, relative_period:, jump_days:, engine:, serializer:)
      end
    end

    class FactoryStub
      attr_reader :pipe

      def initialize(git_strategy: GitStrategyStub.new, pipe: [StringIO.new, StringIO.new], worker: WorkerStub,
                     worktree: WorktreeStub, serializer: Serializer::None)
        @git_strategy = git_strategy
        @pipe = pipe
        @worker = worker
        @worktree = worktree
        @serializer = serializer
      end

      def git_strategy(*) = @git_strategy
      def worker(*) = @worker
      def worktree(*) = @worktree
      def serializer(*) = @serializer
    end

    class GitStrategyStub
      def initialize(commits: [])
        @commits = commits
      end

      def resolve_commits_with_interval(*) = @commits
    end

    class WorkerStub
      def self.perform(*); end
      def self.schedule(*); end
    end

    class WorktreeStub
      def self.prepare; end
      def self.checkout(sha); end
      def self.remove; end
    end

    class EngineStub
      def self.run(*) = ''
    end
  end
end
