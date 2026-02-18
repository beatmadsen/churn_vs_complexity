# frozen_string_literal: true

require 'test_helper'

class GoIntegrationTest < TLDR
  def test_should_complete_go_csv_pipeline
    # Given: a Normal::Config for Go with CSV output
    config = ChurnVsComplexity::Normal::Config.new(
      language: :go,
      serializer: :csv,
      since: '2000-01-01',
    )
    config.validate!

    # When: we run the full check pipeline against Go test files
    result = config.checker.check(folder: 'tmp/test-support/go')

    # Then: it should return non-empty results (one row per .go file)
    refute_nil result, 'Should return a result'
    refute_empty result, 'Should contain data for .go files'
  end
end
