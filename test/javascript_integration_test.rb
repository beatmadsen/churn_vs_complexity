# frozen_string_literal: true

require 'test_helper'

class JavascriptIntegrationTest < TLDR

  def test_javascript_summary_completes
    config = ChurnVsComplexity::Config.new(
      language: :javascript,
      serializer: :summary,
      since: '2000-01-01',
    )
    config.validate!
    result = config.to_engine.check(folder: 'tmp/test-support/javascript')

    expected_summary_contents = <<~EXPECTED
      Number of observations: 4

      Churn:
      Mean 0.0, Median 0.0

      Complexity:
      Mean 5.0, Median 4.0

      Product of churn and complexity:
      Mean 0.0, Median 0.0
    EXPECTED

    assert result.include?(expected_summary_contents.strip), "Expected summary contents not found in the result"
  end
end
