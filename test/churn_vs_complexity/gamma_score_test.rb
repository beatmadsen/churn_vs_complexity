# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class GammaScoreTest < TLDR
    def test_should_calculate_harmonic_mean_of_churn_and_complexity
      # Given: churn=10, complexity=5
      # When: gamma = 2*10*5 / (10+5) = 100/15 ≈ 6.667
      result = GammaScore.calculate(10, 5.0)

      # Then: harmonic mean (with epsilon for zero-safety)
      assert_in_delta 6.667, result, 0.01
    end

    def test_should_handle_zero_churn_without_division_error
      # Given: churn=0 (with epsilon protection)
      result = GammaScore.calculate(0, 10.0)

      # Then: result should be near zero, not raise error
      assert_in_delta 0.0, result, 0.01
    end

    def test_should_handle_zero_complexity_without_division_error
      result = GammaScore.calculate(10, 0.0)
      assert_in_delta 0.0, result, 0.01
    end
  end
end
