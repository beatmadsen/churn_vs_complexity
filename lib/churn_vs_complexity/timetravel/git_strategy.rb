# frozen_string_literal: true

module ChurnVsComplexity
  module Timetravel
    class GitStrategy
      def initialize(folder:)
        @repo = Git.open(folder)
        @folder = folder
      end

      def checkout_in_worktree(worktree_folder, sha)
        command = "(cd #{worktree_folder} && git checkout #{sha}) > /dev/null 2>&1"
        `#{command}`
      end

      def resolve_commits_with_interval(git_period:, jump_days:)
        candidates = @repo.log(1_000_000).since(git_period.effective_start_date).until(git_period.end_date).to_a

        commits_by_date = candidates.filter { |c| c.date.to_date >= git_period.effective_start_date }
                                    .group_by { |c| c.date.to_date }

        found_dates = GitDate.select_dates_with_at_least_interval(commits_by_date.keys, jump_days)

        found_dates.map { |date| commits_by_date[date].max_by(&:date) }
      end

      def add_worktree(wt_folder)
        command = "(cd #{@folder} && git worktree add -f #{wt_folder}) > /dev/null 2>&1"
        `#{command}`
      end

      def remove_worktree(worktree_folder)
        command = "(cd #{worktree_folder} && git worktree remove -f #{worktree_folder}) > /dev/null 2>&1"
        `#{command}`
      end
    end
  end
end
