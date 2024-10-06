# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Serializer
    module Timetravel
      class StatsCalculatorTest < TLDR
        def test_summaries
          result = [
            ['sha_1', { 'end_date' => '2024-01-01', 'values' => [[1, 2], [3, 4]] }],
            ['sha_2', { 'end_date' => '2024-01-02', 'values' => [[5, 6], [7, 8]] }],
          ]

          summaries = StatsCalculator.new.summaries(result)

          assert_equal [
            {
              'end_date' => '2024-01-01',
              'mean_churn' => 2,
              'median_churn' => 3,
              'mean_complexity' => 3,
              'median_complexity' => 4,
              'mean_alpha_score' => 0.16668055532407794,
              'median_alpha_score' => 0.33334444425926235,
              'mean_beta_score' => 0.16668055532407794,
              'median_beta_score' => 0.33334444425926235,
            },
            {
              'end_date' => '2024-01-02',
              'mean_churn' => 6,
              'median_churn' => 7,
              'mean_complexity' => 7,
              'median_complexity' => 8,
              'mean_alpha_score' => 0.8333361110648156,
              'median_alpha_score' => 1.0,
              'mean_beta_score' => 0.8333361110648156,
              'median_beta_score' => 1.0,
            },
          ], summaries
        end
      end
    end
  end
end
