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

        product = values_by_file.map { |_, values| values[0].to_f * values[1].to_f }
        mean_product = product.sum / product.size
        median_product = product.sort[product.size / 2]

        end_date = result[:git_period].end_date

        {
          mean_churn:,
          median_churn:,
          mean_complexity:,
          median_complexity:,
          mean_product:,
          median_product:,
          end_date:,
        }
      end
    end
  end
end
