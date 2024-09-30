# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    module SummaryHash
      def self.serialize(result)
        values_by_file = result[:values_by_file]
        churn_values = values_by_file.map { |_, values| values[0].to_f }
        complexity_values = values_by_file.map { |_, values| values[1].to_f }

        mean_churn = churn_values.sum / churn_values.size
        median_churn = churn_values.sort[churn_values.size / 2]
        mean_complexity = complexity_values.sum / complexity_values.size
        median_complexity = complexity_values.sort[complexity_values.size / 2]

        alpha_score = values_by_file.map do |_, values|
          # harmonic mean of churn and complexity
          epsilon = 0.0001
          churn = values[0].to_f + epsilon
          complexity = values[1].to_f + epsilon
          (2 * churn * complexity) / (churn + complexity)
        end

        mean_alpha_score = alpha_score.sum / alpha_score.size
        median_alpha_score = alpha_score.sort[alpha_score.size / 2]

        beta_score = values_by_file.map do |_, values|
          # geometric mean of churn and complexity
          epsilon = 0.0001
          churn = values[0].to_f + epsilon
          complexity = values[1].to_f + epsilon
          Math.sqrt(churn * complexity)
        end

        mean_beta_score = beta_score.sum / beta_score.size
        median_beta_score = beta_score.sort[beta_score.size / 2]

        end_date = result[:git_period].end_date

        {
          mean_churn:,
          median_churn:,
          mean_complexity:,
          median_complexity:,
          mean_alpha_score:,
          median_alpha_score:,
          mean_beta_score:,
          median_beta_score:,
          end_date:,
        }
      end
    end
  end
end
