# frozen_string_literal: true

require 'git'

module ChurnVsComplexity
  module Churn
    module GitCalculator
      class << self
        def calculate(folder:, file:, since:)
          git_dir = File.join(folder, '.git')
          formatted_date = since.strftime('%Y-%m-%d')
          cmd = %Q(git --git-dir #{git_dir} --work-tree #{folder} log --format="%H" --follow --since="#{formatted_date}" -- #{file} | wc -l)
          `#{cmd}`.to_i
        end

        def date_of_latest_commit(folder:)
          repo(folder).log.first.date
        end

        private

        def repo(folder)
          repos[folder] ||= Git.open(folder)
        end

        def repos
          @repos ||= {}
        end
      end
    end
  end
end
