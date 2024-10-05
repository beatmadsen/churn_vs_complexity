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

          max_churn = churn_values.max
          min_churn = churn_values.min
          max_complexity = complexity_values.max
          min_complexity = complexity_values.min

          epsilon = 0.0001
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
            max_churn:,
            min_churn:,
            mean_complexity:,
            median_complexity:,
            max_complexity:,
            min_complexity:,
            mean_gamma_score:,
            median_gamma_score:,
            end_date:,
          }
        end
      end
    end
  end
end
