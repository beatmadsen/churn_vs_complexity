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

      Gamma score:
      Mean 0.00019999204658760359, Median 0.00019999500024998754
    EXPECTED

    assert result.include?(expected_summary_contents.strip),
           "Expected summary contents not found in the result: #{result}"
  end
end
