# frozen_string_literal: true

module ChurnVsComplexity
  class GitStrategy
    EMPTY_TREE_SHA = '4b825dc642cb6eb9a060e54bf8d69288fbee4904'

    def initialize(folder:)
      @repo = Git.open(folder)
      @folder = folder
    end

    def valid_commit?(commit:)
      @repo.object(commit)
      true
    rescue Git::GitExecuteError
      false
    end

    def object(commit)
      commit.is_a?(Git::Object::Commit) ? commit : @repo.object(commit)
    end

    def surrounding(commit:)
      current = object(commit)
      child_sha = `git -C #{@folder} log --reverse --ancestry-path #{current.sha}..HEAD --format=%H`.lines.first&.chomp
      next_commit = child_sha&.empty? ? nil : child_sha
      [current.parent&.sha, next_commit]
    end

    def changes(commit:)
      commit_object = @repo.object(commit)
      diff_from_parent(commit_object).map do |change|
        { path: change.path, type: change.type.to_sym }
      end
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

    private

    def diff_from_parent(commit_object)
      base = commit_object.parent
      base ? base.diff(commit_object) : @repo.diff(EMPTY_TREE_SHA, commit_object.sha)
    end
  end
end
