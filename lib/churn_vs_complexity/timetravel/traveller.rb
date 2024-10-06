# frozen_string_literal: true

require 'digest'
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

        chunked = commits.each_slice(3).map do |chunk|
          { chunk:, pipe: @factory.pipe }
        end.to_a

        chunked.map.with_index do |c_and_p, i|
          c_and_p => { chunk:, pipe: }
          worktree_folder = git_strategy.prepare_worktree(tt_folder, i)

          #  TODO: why is the root folder changed too upon checkout?
          #       It wasn't that way when I ran the commands manually
          schedule_work(chunk:, worktree_folder:, pipe:)
        end

        combined = chunked.map do |c_and_p|
          c_and_p => { pipe: }
          read_result(pipe)
        end.reduce({}, :merge)

        # pids.each do |pid|
        #   Process.waitpid(pid)
        # end

        puts serializer.serialize(combined)
      end

      private

      def read_result(pipe)
        pipe[1].close
        #  read a single line from the pipe
        part = begin
          line = pipe[0].gets
          JSON.parse(line)
        rescue StandardError => e
          warn "Error parsing JSON: #{e}"
          {}
        end
        pipe[0].close
        part
      end

      def schedule_work(chunk:, worktree_folder:, pipe:)
        @factory.worker(engine: @engine, git_strategy: @git_strategy)
                .schedule(chunk:, worktree_folder:, pipe:)
      end

      def tt_folder
        folder_hash = Digest::SHA256.hexdigest(folder)
        File.expand_path("../../tmp/timetravel/#{folder_hash}", __dir__)
      end

      def serializer
        case @serializer
        when :csv
          Serializer::Timetravel::CSV
        when :graph
          Serializer::Timetravel::Graph.new(git_period: @git_period, relative_period: @relative_period,
                                            jump_days: @jump_days,)
        end
      end
    end
  end
end
