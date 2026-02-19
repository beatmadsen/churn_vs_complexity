# frozen_string_literal: true

module ChurnVsComplexity
  module Normal
    module Serializer
      module SummaryHash
        class << self
          def serialize(result)
            values_by_file = result[:values_by_file]
            end_date = result[:git_period].end_date

            return empty_summary(end_date) if values_by_file.empty?

            churn_values = values_by_file.map { |_, values| values[0].to_f }
            complexity_values = values_by_file.map { |_, values| values[1].to_f }
            gamma_scores = values_by_file.map { |_, values| GammaScore.calculate(values[0], values[1]) }

            stats(churn_values).transform_keys { |k| :"#{k}_churn" }
              .merge(stats(complexity_values).transform_keys { |k| :"#{k}_complexity" })
              .merge(stats(gamma_scores).slice(:mean, :median).transform_keys { |k| :"#{k}_gamma_score" })
              .merge(end_date:)
          end

          private

          def stats(values)
            { mean: values.sum / values.size, median: values.sort[values.size / 2], max: values.max, min: values.min }
          end

          def empty_summary(end_date)
            {
              mean_churn: 0.0,
              median_churn: 0.0,
              max_churn: 0.0,
              min_churn: 0.0,
              mean_complexity: 0.0,
              median_complexity: 0.0,
              max_complexity: 0.0,
              min_complexity: 0.0,
              mean_gamma_score: 0.0,
              median_gamma_score: 0.0,
              end_date:,
            }
          end
        end
      end
    end
  end
end
