# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class RiskAnnotatorTest < TLDR
    def test_should_annotate_files_with_gamma_and_risk
      values_by_file = {
        'lib/simple.rb' => [3, 2.0],
        'lib/complex.rb' => [40, 30.0],
      }

      entries = RiskAnnotator.annotate(values_by_file)

      assert_equal 2, entries.size
      simple = entries.find { |e| e[:file] == 'lib/simple.rb' }
      assert_equal 'low', simple[:risk]
      assert simple.key?(:gamma_score)
      assert simple.key?(:recommendation)
    end

    def test_should_compute_risk_summary_counts
      entries = [
        { risk: 'low' },
        { risk: 'high' },
        { risk: 'high' },
        { risk: 'medium' },
      ]

      summary = RiskAnnotator.risk_summary(entries)

      assert_equal 2, summary[:high_risk]
      assert_equal 1, summary[:medium_risk]
      assert_equal 1, summary[:low_risk]
    end
  end
end
