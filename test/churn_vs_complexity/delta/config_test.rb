# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Delta
    class ConfigTest < TLDR
      def test_commits_with_HEAD_is_allowed
        Config.new(language: :java, serializer: :none, commits: ['HEAD']).validate!
      end

      def test_valid_commit_does_not_raise_validation_error
        Config.new(
          language: :ruby,
          serializer: :none,
          commits: ['aabbccdd'],
        ).validate!
      end

      def test_should_accept_7_char_short_sha
        # Given: a 7-character SHA (git log --oneline default)
        # When/Then: should not raise
        Config.new(
          language: :ruby,
          serializer: :none,
          commits: ['c220402'],
        ).validate!
      end

      def test_commits_with_one_bad_commit_raises_validation_error
        assert_raises(ValidationError) do
          Config.new(
            language: :ruby,
            serializer: :none,
            commits: %w[aabbccdd bad_commit],
          ).validate!
        end
      end
    end
  end
end
