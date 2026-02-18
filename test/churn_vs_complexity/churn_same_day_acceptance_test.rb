# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class ChurnSameDayAcceptanceTest < TLDR
    # date_of_first_commit returns 2024-10-12 for this repo (30th most recent commit)
    # lib/churn_vs_complexity.rb has 6 commits since 2024-10-12T00:00:00
    # With bare date --since="2024-10-12": git returns only 3 (excludes same-day commits)
    # With time --since="2024-10-12T00:00:00": git returns 6 (includes same-day commits)

    FILE = 'lib/churn_vs_complexity.rb'

    def test_should_count_commits_on_the_earliest_date
      # Given: lib/churn_vs_complexity.rb has commits on 2024-10-12
      #        date_of_first_commit returns 2024-10-12, which becomes the earliest_date
      #        since is set earlier so it doesn't override date_of_first_commit
      since_date = Date.new(2024, 1, 1)

      # When: we calculate churn
      churn = Churn::GitCalculator.calculate(
        folder: ROOT_PATH,
        file: FILE,
        since: since_date,
      )

      # Then: churn should match the count from git log --since with time component
      #        (not the lower count from bare date --since)
      expected = `git --git-dir #{ROOT_PATH}/.git --work-tree #{ROOT_PATH} log --format="%H" --follow --since="2024-10-12T00:00:00" -- #{FILE} | wc -l`.to_i
      assert_equal expected, churn,
                   "Churn should include same-day commits. Expected #{expected}, got #{churn}"
    end
  end
end
