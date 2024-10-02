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

        epsilon = 0.0001
        # TODO: right now the normalistion factor is only for 1 commit. It should be for the whole period.
        churn_normailisation_factor = churn_values.max - churn_values.min + epsilon
        complexity_normailisation_factor = complexity_values.max - complexity_values.min + epsilon
        
        alpha_score = values_by_file.map do |_, values|
          
          churn = (values[0].to_f + epsilon) / churn_normailisation_factor
          complexity = (values[1].to_f + epsilon) / complexity_normailisation_factor

          (2 * churn * complexity) / (churn + complexity)          
        end

        mean_alpha_score = alpha_score.sum / alpha_score.size
        median_alpha_score = alpha_score.sort[alpha_score.size / 2]

        beta_score = values_by_file.map do |_, values|
          # geometric mean of churn and complexity
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
