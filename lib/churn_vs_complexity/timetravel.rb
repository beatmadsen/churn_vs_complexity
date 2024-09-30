# frozen_string_literal: true

module ChurnVsComplexity
  # TODO: unit test and integration test
  class Timetravel
    def initialize(since:, relative_period:, engine:, serializer:, jump_days: 30)
      @relative_period = relative_period
      @engine = engine
      @jump_days = jump_days
      @serializer = serializer
      @git_period = GitDate.git_period(since, Time.now.to_date)
    end

    def go(folder:)
      repo = Git.open(folder)

      commits = resolve_commits_with_interval(repo)

      chunked = commits.each_slice(3).map do |chunk|
        { chunk:, pipe: IO.pipe }
      end.to_a

      pids = chunked.map do |c_and_p|
        c_and_p => { chunk:, pipe: }
        fork do
          results = chunk.to_h do |commit|
            sha = commit.sha
            # locate tmp folder relative to this file
            tt_folder = File.expand_path("../../../tmp/timetravel/#{sha}", __FILE__)

            unless File.directory?(tt_folder)
              FileUtils.mkdir_p(tt_folder)
              command = "cd #{folder} && git worktree add -f #{tt_folder} #{sha}"
              `#{command}`
            end
            result = @engine.check(folder: tt_folder)

            # cleanup
            command = "cd #{folder} && git worktree remove -f #{tt_folder}"
            `#{command}`

            [sha, result]
          end
          pipe[1].puts(JSON.dump(results))
          pipe[1].close
        end
      end

      combined = chunked.map do |c_and_p|
        c_and_p => { chunk:, pipe: }
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
      end.reduce({}, :merge)

      pids.each do |pid|
        Process.waitpid(pid)
      end

      puts serializer.serialize(combined)
    end

    private

    def resolve_commits_with_interval(repo)
      candidates = repo.log(1_000_000).since(@git_period.effective_start_date).until(@git_period.end_date).to_a

      commits_by_date = candidates.filter { |c| c.date.to_date >= @git_period.effective_start_date }
                                  .group_by { |c| c.date.to_date }

      found_dates = GitDate.select_dates_with_at_least_interval(commits_by_date.keys, @jump_days)

      found_dates.map { |date| commits_by_date[date].max_by(&:date) }
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
