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
end
