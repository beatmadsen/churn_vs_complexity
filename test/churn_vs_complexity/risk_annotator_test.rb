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

    def test_should_classify_with_language_aware_thresholds
      # Given: a file whose gamma score (~30) is above DEFAULT_HIGH (25) but
      # within Ruby's higher thresholds
      values_by_file = { 'lib/moderate.rb' => [30, 30.0] }
      # gamma = 2*30*30 / (30+30) = 30.0

      # When: annotating for Ruby (high Flog scores need higher thresholds)
      ruby_entries = RiskAnnotator.annotate(values_by_file, language: :ruby)

      # When: annotating for Java (default thresholds are appropriate)
      java_entries = RiskAnnotator.annotate(values_by_file, language: :java)

      # Then: Ruby should NOT classify this as high risk (thresholds are higher)
      ruby_risk = ruby_entries.first[:risk]
      refute_equal 'high', ruby_risk, "Gamma ~30 should not be high risk for Ruby (Flog scores run much higher)"

      # Then: Java SHOULD classify this as high risk (default thresholds apply)
      java_risk = java_entries.first[:risk]
      assert_equal 'high', java_risk, "Gamma ~30 should be high risk for Java"
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
