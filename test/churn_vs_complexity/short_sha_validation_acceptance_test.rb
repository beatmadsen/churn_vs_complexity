# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class ShortShaValidationAcceptanceTest < TLDR
    def test_should_accept_7_char_sha_from_git_log_oneline
      # Given: a 7-character SHA (the default output of git log --oneline)
      seven_char_sha = `git -C #{ROOT_PATH} log --oneline -1 --format=%h`.chomp

      # When/Then: validate! should not raise for a 7-char SHA
      config = Delta::Config.new(
        language: :ruby,
        serializer: :none,
        commits: [seven_char_sha],
      )
      config.validate!
    end

    def test_should_accept_shas_of_various_short_lengths
      # Given: short SHAs of common lengths (7 through 12 chars)
      shas = (7..12).map { |len| 'abcdef1234567890abcd'[0, len] }

      # When/Then: all should be accepted by validate!
      shas.each do |sha|
        config = Delta::Config.new(
          language: :ruby,
          serializer: :none,
          commits: [sha],
        )
        config.validate!
      end
    end
  end
end
