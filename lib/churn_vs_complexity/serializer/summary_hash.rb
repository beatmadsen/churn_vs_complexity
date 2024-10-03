# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    module SummaryHash
      class << self
        def serialize(result)
          values_by_file = result[:values_by_file]
          churn_values = values_by_file.map { |_, values| values[0].to_f }
          complexity_values = values_by_file.map { |_, values| values[1].to_f }

          mean_churn = churn_values.sum / churn_values.size
          median_churn = churn_values.sort[churn_values.size / 2]
          mean_complexity = complexity_values.sum / complexity_values.size
          median_complexity = complexity_values.sort[complexity_values.size / 2]

          epsilon = 0.0001

          churn_values.min
          churn_values.max
          complexity_values.min
          complexity_values.max

          gamma_score = values_by_file.map do |_, values|
            # unnormalised harmonic mean of churn and complexity,
            # since the summary needs to be comparable over time
            churn = values[0].to_f + epsilon
            complexity = values[1].to_f + epsilon

            (2 * churn * complexity) / (churn + complexity)
          end

          mean_gamma_score = gamma_score.sum / gamma_score.size
          median_gamma_score = gamma_score.sort[gamma_score.size / 2]

          end_date = result[:git_period].end_date

          {
            mean_churn:,
            median_churn:,
            mean_complexity:,
            median_complexity:,
            mean_gamma_score:,
            median_gamma_score:,
            end_date:,
          }
        end

        private

        def normalise(score, min, max, epsilon) = (score + epsilon - min) / (epsilon + max - min)
      end
    end
  end
end
