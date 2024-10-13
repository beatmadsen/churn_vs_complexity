# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    CONCURRENCY = Etc.nprocessors * 2

    class MultiChecker
      def initialize(serializer:, factory:, commits:, language:, excluded:)
        @serializer = serializer
        @excluded = excluded
        @factory = factory
        @commits = commits
        @language = language
      end

      def check(folder:)
        indexed_commits = @commits.map.with_index do |commit, index|
          [commit, index]
        end

        results = []

        concurrency = [CONCURRENCY, indexed_commits.size].min

        concurrency.times.map do |ci|
          Thread.new do
            loop do
              commit, index = indexed_commits.shift
              break if commit.nil?
              result = check_commit(commit:, data_isolation_id: ci, folder:)
              results[index] = result
            end
          end
        end.each(&:join)

        @serializer.serialize(results)
      end

      private

      def check_commit(commit:, data_isolation_id:, folder:)
        Checker.new(serializer: Serializer::PassThrough, factory: @factory, commit:, language: @language, excluded: @excluded, data_isolation_id:)
               .check(folder:)
      end
    end
  end
end
