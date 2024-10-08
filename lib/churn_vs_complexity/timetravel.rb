# frozen_string_literal: true

require 'digest'
require_relative 'timetravel/traveller'

module ChurnVsComplexity
  module Timetravel
    class Factory
      def self.git_strategy(folder:) = GitStrategy.new(folder:)
      def self.pipe = IO.pipe
      def self.worker(engine:, worktree:) = Worker.new(engine:, worktree:)
      def self.worktree(root_folder:, git_strategy:, number:) = Worktree.new(root_folder:, git_strategy:, number:)
    end

    class Worktree
      attr_reader :folder

      def initialize(root_folder:, git_strategy:, number:)
        @root_folder = root_folder
        @git_strategy = git_strategy
        @number = number
      end

      def prepare
        @folder = prepare_worktree
      end

      def checkout(sha)
        raise Error, 'Worktree not prepared' if @folder.nil?

        @git_strategy.checkout_in_worktree(@folder, sha)
      end

      def remove
        raise Error, 'Worktree not prepared' if @folder.nil?

        @git_strategy.remove_worktree(@folder)
      end

      private

      def tt_folder
        folder_hash = Digest::SHA256.hexdigest(@root_folder)[0..7]
        File.expand_path("../../tmp/timetravel/#{folder_hash}", __dir__)
      end

      def prepare_worktree
        worktree_folder = File.join(tt_folder, "worktree_#{@number}")

        unless File.directory?(worktree_folder)
          begin
            FileUtils.mkdir_p(worktree_folder)
          rescue StandardError
            nil
          end
          @git_strategy.add_worktree(worktree_folder)
        end

        worktree_folder
      end
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

      def add_worktree(wt_folder)
        command = "cd #{@folder} && git worktree add -f #{wt_folder}"
        `#{command}`
      end

      def remove_worktree(worktree_folder)
        command = "cd #{worktree_folder} && git worktree remove -f #{worktree_folder}"
        `#{command}`
      end
    end
  end
end
