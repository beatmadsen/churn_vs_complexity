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
      $stderr.puts "Found #{commits.size} commits:"
      $stderr.puts commits.map(&:sha)


      # locate tmp folder relative to this file
      tt_folder = File.expand_path('../../../tmp/timetravel/1', __FILE__)
      $stderr.puts "Using #{tt_folder} as the timetravel folder"
      FileUtils.mkdir_p tt_folder

      # find old sha
      sha = repo.log[1].sha[0,7]
      $stderr.puts "Using #{sha} as the old sha"
      command = "cd #{folder} && git worktree add -f #{tt_folder} #{sha}"
      $stderr.puts "Running #{command}"
      `#{command}`
    end

    private

    def resolve_commits_with_interval(repo)
      git_period = GitDate.git_period(@since, Time.now.to_date)
      candidates = repo.log.since(git_period.effective_start_date).until(git_period.end_date).to_a
      $stderr.puts "Found #{candidates.size} candidates"
      
      commits_by_date = candidates.group_by { |c| c.date.to_date }

      found_dates = GitDate.select_dates_with_at_least_interval(commits_by_date.keys, @jump_days)
      
      found_dates.map { |date| commits_by_date[date].max_by(&:date) }
    end
  end
end
