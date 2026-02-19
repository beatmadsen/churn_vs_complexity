# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class RiskClassifierTest < TLDR
    def test_should_classify_low_gamma_as_low_risk
      # Given: a gamma score below the low threshold
      # When: we classify
      result = RiskClassifier.classify(gamma_score: 5.0)

      # Then: risk is low with appropriate recommendation
      assert_equal 'low', result[:risk]
      assert_match(/safe/i, result[:recommendation])
    end

    def test_should_classify_medium_gamma_as_medium_risk
      # Given: a gamma score between low and high thresholds
      result = RiskClassifier.classify(gamma_score: 15.0)

      # Then: risk is medium
      assert_equal 'medium', result[:risk]
      assert_match(/judgement/i, result[:recommendation])
    end

    def test_should_classify_high_gamma_as_high_risk
      # Given: a gamma score above the high threshold
      result = RiskClassifier.classify(gamma_score: 30.0)

      # Then: risk is high
      assert_equal 'high', result[:risk]
      assert_match(/test/i, result[:recommendation])
    end

    def test_should_use_default_thresholds
      # Given: default thresholds (low: 10, high: 25)
      # Then: boundary values should classify correctly
      assert_equal 'low', RiskClassifier.classify(gamma_score: 9.99)[:risk]
      assert_equal 'medium', RiskClassifier.classify(gamma_score: 10.0)[:risk]
      assert_equal 'medium', RiskClassifier.classify(gamma_score: 25.0)[:risk]
      assert_equal 'high', RiskClassifier.classify(gamma_score: 25.01)[:risk]
    end

    def test_should_accept_custom_thresholds
      # Given: custom thresholds
      classifier = RiskClassifier.new(low: 5, high: 15)

      # Then: classification uses those thresholds
      assert_equal 'low', classifier.classify(gamma_score: 4.0)[:risk]
      assert_equal 'medium', classifier.classify(gamma_score: 10.0)[:risk]
      assert_equal 'high', classifier.classify(gamma_score: 16.0)[:risk]
    end

    def test_should_use_higher_thresholds_for_ruby
      # Given: a classifier configured for Ruby (Flog scores run 3-7x higher)
      classifier = RiskClassifier.new(language: :ruby)

      # When: classifying a gamma score that would be high with defaults
      result = classifier.classify(gamma_score: 30.0)

      # Then: Ruby thresholds treat this as NOT high risk
      refute_equal 'high', result[:risk],
                   'Gamma 30 should not be high for Ruby — Flog scores are much higher than other tools'
    end
  end
end
