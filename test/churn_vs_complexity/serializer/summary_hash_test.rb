# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Serializer
    GitPeriod = Data.define(:requested_start_date, :end_date)

    class SummaryHashTest < TLDR
      def test_that_x
        values_by_file = {
          'file1' => [1, 4],
          'file2' => [2, 2],
          'file3' => [3, 27],
          'file4' => [4, 3],
          'file5' => [5, 3],
        }
        end_date = Date.new(2024, 1, 1)
        git_period = GitPeriod.new(requested_start_date: nil, end_date:)
        result = SummaryHash.serialize({ values_by_file:, git_period: })
        assert_equal({
                       mean_churn: 3.0,
                       median_churn: 3.0,
                       mean_complexity: 7.8,
                       median_complexity: 3.0,
                       mean_gamma_score: 3.235835943461319,
                       median_gamma_score: 3.428673469329448,
                       end_date:,
                     },
                     result,)
      end
    end
  end
end
