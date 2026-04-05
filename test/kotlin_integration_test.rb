# frozen_string_literal: true

require 'test_helper'

class KotlinIntegrationTest < TLDR
  def test_should_complete_kotlin_csv_pipeline
    skip 'lizard not installed' unless system('which lizard > /dev/null 2>&1')

    # Given: a Normal::Config for Kotlin with CSV output
    config = ChurnVsComplexity::Normal::Config.new(
      language: :kotlin,
      serializer: :csv,
      since: '2000-01-01',
    )
    config.validate!

    # When: we run the full check pipeline against Kotlin test files
    result = config.checker.check(folder: 'tmp/test-support/kotlin')

    # Then: it should return non-empty results (one row per .kt file)
    refute_nil result, 'Should return a result'
    refute_empty result, 'Should contain data for .kt files'
  end
end
