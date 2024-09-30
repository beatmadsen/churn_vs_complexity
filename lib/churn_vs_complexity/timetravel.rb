# frozen_string_literal: true

module ChurnVsComplexity
  class Timetravel
    def initialize(since:, engine:, jump_days: 30)
      @since = since
      @engine = engine
      @jump_days = jump_days
    end

    def go(folder:)
      repo = Git.open(folder)

      commits = resolve_commits_with_interval(repo)
      chunked = commits.each_slice(3).map do |chunk| 
        { chunk:, pipe: IO.pipe }
      end.to_a

      pids = chunked.map do | c_and_p |
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
            [sha, "spiderman"]            
          end
          pipe[1].puts(JSON.dump(results))
          pipe[1].close
        end
      end

      combined = chunked.map do |c_and_p|
        c_and_p => { chunk:, pipe: }
        pipe[1].close
        # read a single line from the pipe
        part = begin
          line = pipe[0].gets
          JSON.parse(line)
        rescue => e
          $stderr.puts "Error parsing JSON: #{e}"
          $stderr.puts "Line: #{line}"
          {}
        end
        pipe[0].close
        part
      end.reduce({}, :merge)

      pids.each do |pid|
        Process.waitpid(pid)
      end

      puts combined

      "Done with timetravel"
    end

    private

    def resolve_commits_with_interval(repo)
      git_period = GitDate.git_period(@since, Time.now.to_date)
      candidates = repo.log.since(git_period.effective_start_date).until(git_period.end_date).to_a
      
      commits_by_date = candidates.group_by { |c| c.date.to_date }

      found_dates = GitDate.select_dates_with_at_least_interval(commits_by_date.keys, @jump_days)
      
      found_dates.map { |date| commits_by_date[date].max_by(&:date) }
    end
  end
end
