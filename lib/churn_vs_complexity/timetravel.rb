# frozen_string_literal: true

require_relative 'timetravel/traveller'
require_relative 'timetravel/worktree'

module ChurnVsComplexity
  module Timetravel
    class Factory
      def self.git_strategy(folder:) = GitStrategy.new(folder:)
      def self.pipe = IO.pipe
      def self.worker(engine:, worktree:) = Worker.new(engine:, worktree:)
      def self.worktree(root_folder:, git_strategy:, number:) = Worktree.new(root_folder:, git_strategy:, number:)
      def self.serializer(**args) = Serializer::Timetravel.resolve(**args)
    end

    class Worker
      def initialize(engine:, worktree:)
        @engine = engine
        @worktree = worktree
      end

      def schedule(chunk:, pipe:)
        fork do
          results = chunk.to_h do |commit|
            sha = commit.sha
            @worktree.checkout(sha)
            result = @engine.check(folder: @worktree.folder)
            [sha, result]
          end
          @worktree.remove
          pipe[1].puts(JSON.dump(results))
          pipe[1].close
        end
      end
    end

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
