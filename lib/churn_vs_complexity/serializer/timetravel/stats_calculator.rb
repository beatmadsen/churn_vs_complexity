# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    module Timetravel
      class StatsCalculator
        # ['some_sha', { 'end_date' => '2024-01-01', 'values' => [[1, 2], [3, 4]] }]
        # TODO: quality sqores should be caluclated by file, not by sha. We will then aggregate them to mean and median quality scores for all files
        def summaries(result)
          observations = result.sort_by do |_sha, summary|
            summary['end_date']
          end.map { |entry| entry[1] }

          quality_calculator = QualityCalculator.new(**extrema(observations))
          observations.map do |o|
            end_date = o['end_date']
            scores = o['values'].map do |(churn, complexity)|
              alpha = quality_calculator.alpha_score(churn, complexity)
              beta = quality_calculator.beta_score(churn, complexity)
              [churn, complexity, alpha, beta]
            end
            {
              'end_date' => end_date,
              'mean_churn' => mean(scores.map { |s| s[0] }),
              'median_churn' => median(scores.map { |s| s[0] }),
              'mean_complexity' => mean(scores.map { |s| s[1] }),
              'median_complexity' => median(scores.map { |s| s[1] }),
              'mean_alpha_score' => mean(scores.map { |s| s[2] }),
              'median_alpha_score' => median(scores.map { |s| s[2] }),
              'mean_beta_score' => mean(scores.map { |s| s[3] }),
              'median_beta_score' => median(scores.map { |s| s[3] }),
            }
          end
        end

        private

        def extrema(observations)
          churn_series = observations.flat_map { |o| o['values'] }.map { |(churn, _)| churn }
          max_churn = churn_series.max
          min_churn = churn_series.min

          complexity_series = observations.flat_map { |o| o['values'] }.map { |(_, complexity)| complexity }
          max_complexity = complexity_series.max
          min_complexity = complexity_series.min

          { max_churn:, min_churn:, max_complexity:, min_complexity: }
        end

        def mean(series)
          series.sum / series.size
        end

        def median(series)
          sorted = series.sort
          sorted[sorted.size / 2]
        end
      end
    end
  end
end
