# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Delta
    class ConfigTest < TLDR
      def test_commits_with_HEAD_raises_validation_error
        assert_raises(ValidationError) do
          Config.new(
            language: :ruby,
            serializer: :none,
            commits: ['HEAD'],
          ).validate!
        end
      end

      def test_valid_commit_does_not_raise_validation_error
        Config.new(
          language: :ruby,
          serializer: :none,
          commits: ['aabbccdd'],
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
