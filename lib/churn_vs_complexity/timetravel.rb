# frozen_string_literal: true

require_relative 'timetravel/traveller'

module ChurnVsComplexity
  module Timetravel
    class Factory
      def self.git_strategy(folder:) = GitStrategy.new(folder:)
      def self.pipe = IO.pipe
      def self.worker(engine:, git_strategy:) = Worker.new(engine:, git_strategy:)
    end

    class Worker
      def initialize(engine:, git_strategy:)
        @engine = engine
        @git_strategy = git_strategy
      end

      def schedule(chunk:, worktree_folder:, pipe:)
        fork do
          results = chunk.to_h do |commit|
            sha = commit.sha
            git_strategy.checkout_in_worktree(worktree_folder, sha)
            result = @engine.check(folder: worktree_folder)
            [sha, result]
          end
          git_strategy.remove_worktree(worktree_folder)
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
        command = "cd #{worktree_folder} && git checkout #{sha}"
        `#{command}`
      end

      def resolve_commits_with_interval(git_period:, jump_days:)
        candidates = @repo.log(1_000_000).since(git_period.effective_start_date).until(git_period.end_date).to_a

        commits_by_date = candidates.filter { |c| c.date.to_date >= git_period.effective_start_date }
                                    .group_by { |c| c.date.to_date }

        found_dates = GitDate.select_dates_with_at_least_interval(commits_by_date.keys, jump_days)

        found_dates.map { |date| commits_by_date[date].max_by(&:date) }
      end

      def prepare_worktree(tt_folder, index)
        worktree_folder = File.join(tt_folder, "worktree_#{index}")

        unless File.directory?(worktree_folder)
          begin
            FileUtils.mkdir_p(worktree_folder)
          rescue StandardError
            nil
          end
          # TODO: instead of one worktree per commit, use a few worktrees and checkout new commits on them
          command = "cd #{@folder} && git worktree add -f #{worktree_folder}"
          `#{command}`
        end

        worktree_folder
      end

      def remove_worktree(worktree_folder)
        command = "cd #{worktree_folder} && git worktree remove -f #{worktree_folder}"
        `#{command}`
      end
    end
  end
end
