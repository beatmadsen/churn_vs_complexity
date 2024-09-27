# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class EngineTest < TLDR
    def setup
      @latest_commit_date = Date.new(2024, 3, 15)
      @latest_commit_time = @latest_commit_date.to_time
    end

    def test_git_period_with_nil_since
      period = ChurnVsComplexity::GitDate.git_period(nil, @latest_commit_time)
      assert_equal @latest_commit_date, period.end_date
      assert_equal Time.at(0).to_date, period.effective_start_date
      assert_nil period.requested_start_date
    end

    def test_git_period_with_symbol_since
      period = ChurnVsComplexity::GitDate.git_period(:month, @latest_commit_time)
      assert_equal @latest_commit_date, period.end_date
      assert_equal Date.new(2024, 2, 15), period.effective_start_date
      assert_equal Date.new(2024, 2, 15), period.requested_start_date
    end

    def test_git_period_with_string_since
      period = ChurnVsComplexity::GitDate.git_period('2024-01-01', @latest_commit_time)
      assert_equal @latest_commit_date, period.end_date
      assert_equal Date.new(2024, 1, 1), period.effective_start_date
      assert_equal Date.new(2024, 1, 1), period.requested_start_date
    end

    def test_git_period_with_invalid_since_type
      assert_raises ChurnVsComplexity::Error do
        ChurnVsComplexity::GitDate.git_period(123, @latest_commit_time)
      end
    end

    def test_git_period_with_invalid_since_symbol_value
      assert_raises ChurnVsComplexity::Error do
        ChurnVsComplexity::GitDate.git_period(:invalid, @latest_commit_time)
      end
    end
  end

  def test_select_dates_with_at_least_interval_given_empty_array
    # Test case 1: Empty array
    assert_equal [], ChurnVsComplexity::GitDate.select_dates_with_at_least_interval([], 1)
  end

  def test_select_dates_with_at_least_interval_given_single_date

    # Test case 2: Single date
    single_date = Date.new(2023, 1, 1)
    assert_equal [single_date], ChurnVsComplexity::GitDate.select_dates_with_at_least_interval([single_date], 1)
  end

  def test_select_dates_with_at_least_interval_given_dates_with_sufficient_interval
    # Test case 3: Dates with sufficient interval
    dates = [
      Date.new(2023, 1, 1),
      Date.new(2023, 1, 3),
      Date.new(2023, 1, 5),
      Date.new(2023, 1, 7)
    ]
    expected = [
      Date.new(2023, 1, 1),
      Date.new(2023, 1, 3),
      Date.new(2023, 1, 5),
      Date.new(2023, 1, 7)
    ]
    assert_equal expected, ChurnVsComplexity::GitDate.select_dates_with_at_least_interval(dates, 2)
  end

  def test_select_dates_with_at_least_interval_given_dates_with_insufficient_interval
    # Test case 4: Dates with insufficient interval
    dates = [
      Date.new(2023, 1, 1),
      Date.new(2023, 1, 2),
      Date.new(2023, 1, 3),
      Date.new(2023, 1, 5),
      Date.new(2023, 1, 6),
      Date.new(2023, 1, 9)
    ]
    expected = [
      Date.new(2023, 1, 1),
      Date.new(2023, 1, 3),
      Date.new(2023, 1, 5),
      Date.new(2023, 1, 9)
    ]
    assert_equal expected, ChurnVsComplexity::GitDate.select_dates_with_at_least_interval(dates, 2)
  end

  def test_select_dates_with_at_least_interval_given_unsorted_dates
    # Test case 5: Unsorted dates
    unsorted_dates = [
      Date.new(2023, 1, 5),
      Date.new(2023, 1, 1),
      Date.new(2023, 1, 9),
      Date.new(2023, 1, 3)
    ]
    expected = [
      Date.new(2023, 1, 1),
      Date.new(2023, 1, 3),
      Date.new(2023, 1, 5),
      Date.new(2023, 1, 9)
    ]
    assert_equal expected, ChurnVsComplexity::GitDate.select_dates_with_at_least_interval(unsorted_dates, 2)
  end

  def test_select_dates_with_at_least_interval_given_dates_with_negative_interval
    # Test case 6: Dates with negative interval
    dates = [
      Date.new(2023, 1, 1),
      Date.new(2023, 1, 2),
      Date.new(2023, 1, 3),
      Date.new(2023, 1, 5),
      Date.new(2023, 1, 6),
      Date.new(2023, 1, 9)
    ]
    expected = [
      Date.new(2023, 1, 1),
      Date.new(2023, 1, 3),
      Date.new(2023, 1, 5),
      Date.new(2023, 1, 9)
    ]
    assert_equal expected, ChurnVsComplexity::GitDate.select_dates_with_at_least_interval(dates, 2)
  end
end
