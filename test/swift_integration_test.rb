# frozen_string_literal: true

require 'test_helper'

class SwiftIntegrationTest < TLDR
  def test_should_complete_swift_csv_pipeline
    skip 'lizard not installed' unless system('which lizard > /dev/null 2>&1')

    # Given: a Normal::Config for Swift with CSV output
    config = ChurnVsComplexity::Normal::Config.new(
      language: :swift,
      serializer: :csv,
      since: '2000-01-01',
    )
    config.validate!

    # When: we run the full check pipeline against Swift test files
    result = config.checker.check(folder: 'tmp/test-support/swift')

    # Then: it should return non-empty results (one row per .swift file)
    refute_nil result, 'Should return a result'
    refute_empty result, 'Should contain data for .swift files'
  end
end
