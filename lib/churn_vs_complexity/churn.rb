# frozen_string_literal: true

require 'git'

module ChurnVsComplexity
  module Churn
    module Disabled
      def self.calculate(*)
        raise Error, 'Churn is disabled'
      end

      def self.date_of_latest_commit(*) = :disabled
    end

    module GitCalculator
      class << self
        def calculate(folder:, file:, since:)
          git_dir = File.join(folder, '.git')
          earliest_date = [date_of_first_commit(folder:), since].max
          formatted_date = earliest_date.strftime('%Y-%m-%d')
          cmd = %(git --git-dir #{git_dir} --work-tree #{folder} log --format="%H" --follow --since="#{formatted_date}" -- #{file} | wc -l)
          `(#{cmd}) 2>/dev/null`.to_i
        end

        def date_of_latest_commit(folder:)
          repo(folder).log.first.date
        end

        private

        def date_of_first_commit(folder:)
          repo(folder).log.last&.date&.to_date || Time.at(0).to_date
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
