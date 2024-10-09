# frozen_string_literal: true

module ChurnVsComplexity
  # TODO: unit test and integration test
  module Timetravel
    class Traveller
      def initialize(since:, relative_period:, engine:, serializer:, jump_days:, factory: Factory)
        @relative_period = relative_period
        @engine = engine
        @jump_days = jump_days
        @serializer = serializer
        @git_period = GitDate.git_period(since, Time.now.to_date)
        @factory = factory
      end

      def go(folder:)
        git_strategy = @factory.git_strategy(folder:)
        commits = git_strategy.resolve_commits_with_interval(git_period: @git_period, jump_days: @jump_days)

        chunked = make_chunks(commits)
        work_on(chunked:, folder:, git_strategy:)
        combined = chunked.map { |c_and_p| read_result(c_and_p[:pipe]) }.reduce({}, :merge)

        serializer.serialize(combined)
      end

      private

      def work_on(chunked:, folder:, git_strategy:)
        chunked.map.with_index do |c_and_p, i|
          worktree = @factory.worktree(root_folder: folder, git_strategy:, number: i)
          worktree.prepare
          schedule_work(worktree:, **c_and_p)
        end
      end

      def make_chunks(commits)
        commits.each_slice(3).map do |chunk|
          { chunk:, pipe: @factory.pipe }
        end.to_a
      end

      def read_result(pipe)
        part = begin
          JSON.parse(pipe[0].gets)
        rescue StandardError => e
          warn "Error parsing JSON: #{e}"
          {}
        end
        pipe.each(&:close)
        part
      end

      def schedule_work(chunk:, worktree:, pipe:)
        @factory.worker(engine: @engine, worktree:)
                .schedule(chunk:, pipe:)
      end

      def serializer = @factory.serializer(@serializer)
    end
  end
end
