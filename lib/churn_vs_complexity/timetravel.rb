# frozen_string_literal: true

module ChurnVsComplexity
  class Timetravel
    def initialize(since:, engine:)
      @since = since
      @engine = engine
    end

    def go(folder:)
      repo = Git.open(folder)

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
  end
end
