# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Delta
    class CommitHydratorTest < TLDR
      def test_resolves_sha_of_head_commit
        expected_sha = '123abcde'
        git_strategy = GitStrategyStub.new(object_sha: expected_sha)
        hydrator = CommitHydrator.new(git_strategy:, serializer: nil)

        result = hydrator.hydrate('HEAD')

        assert_equal expected_sha, result[:commit]
      end

      GitCommitStub = Data.define(:sha)

      class GitStrategyStub
        def initialize(object_sha: nil)
          @object_sha = object_sha
        end

        def object(commit)
          GitCommitStub.new(sha: @object_sha || commit)
        end
      end
    end
  end
end
