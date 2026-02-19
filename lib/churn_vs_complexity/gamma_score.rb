# frozen_string_literal: true

module ChurnVsComplexity
  module GammaScore
    EPSILON = 0.0001

    def self.calculate(churn, complexity)
      c = churn.to_f + EPSILON
      x = complexity.to_f + EPSILON
      (2 * c * x) / (c + x)
    end
  end
end
