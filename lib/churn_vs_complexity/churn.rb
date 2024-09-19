# frozen_string_literal: true

require 'git'

module ChurnVsComplexity
  module Churn
    module GitCalculator
      class << self
        def calculate(folder:, file:, since:)
          with_follow = calculate_with_follow(folder, file, since)
          with_follow.zero? ? repo(folder).log.path(file).size : with_follow
        end

        def date_of_latest_commit(folder:)
          repo(folder).log.first.date
        end

        private

        def calculate_with_follow(folder, file, since)
          # Format the date as "YYYY-MM-DD"
          formatted_date = since.strftime('%Y-%m-%d')
          # git log --follow --oneline --since="YYYY-MM-DD" <file_path> | wc -l
          `git --git-dir #{File.join(folder,
                                     '.git',)} --work-tree #{folder} log --follow --oneline --since=#{formatted_date} #{file} | wc -l`.to_i
        end

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
