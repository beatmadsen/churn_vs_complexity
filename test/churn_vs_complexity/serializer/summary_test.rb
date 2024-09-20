# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Serializer
    GitPeriod = Data.define(:requested_start_date, :end_date)

    class SummaryTest < TLDR
      def test_that_x
        values_by_file = {
          'file1' => [1, 1],
          'file2' => [2, 16],
          'file3' => [3, 9],
          'file4' => [4, 4],
          'file5' => [5, 1],
        }
        git_period = GitPeriod.new(requested_start_date: nil, end_date: Date.new(2024, 1, 1))
        result = Summary.serialize({ values_by_file:, git_period: })
        assert_equal "Churn until 2024-01-01 vs complexity\n\nNumber of observations: 5\n\nChurn:\nMean 3.0, Median 3.0\n\nComplexity:\nMean 6.2, Median 4.0\n\nProduct of churn and complexity:\nMean 16.2, Median 16.0\n",
                     result
      end
    end
  end
end
