# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    module Timetravel
      EPSILON = 0.0001

      class QualityCalculator
        def initialize(min_churn:, max_churn:, min_complexity:, max_complexity:)
          @min_churn = min_churn
          @max_churn = max_churn
          @min_complexity = min_complexity
          @max_complexity = max_complexity
        end

        def alpha_score(raw_churn, raw_complexity)
          # harmonic mean of normalised churn and complexity
          churn = normalise(raw_churn, @min_churn, @max_churn, EPSILON)
          complexity = normalise(raw_complexity, @min_complexity, @max_complexity, EPSILON)

          (2 * churn * complexity) / (churn + complexity)
        end

        def beta_score(raw_churn, raw_complexity)
          # geometric mean of normalised churn and complexity
          churn = normalise(raw_churn, @min_churn, @max_churn, EPSILON)
          complexity = normalise(raw_complexity, @min_complexity, @max_complexity, EPSILON)

          Math.sqrt(churn * complexity)
        end

        private

        def normalise(score, min, max, epsilon) = (score + epsilon - min) / (epsilon + max - min)
      end
    end
  end
end
