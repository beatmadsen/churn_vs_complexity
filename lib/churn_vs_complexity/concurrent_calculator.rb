# frozen_string_literal: true

module ChurnVsComplexity
  class ConcurrentCalculator
    CONCURRENCY = Etc.nprocessors

    def initialize(complexity:, churn:)
      @complexity = complexity
      @churn = churn
      @churn_results = {}
    end

    def calculate(folder:, files:, since:)
      latest_commit_date = @churn.date_of_latest_commit(folder:)
      @git_period = GitDate.git_period(since, latest_commit_date)
      schedule_churn_calculation(folder, files, @git_period.effective_start_date)
      calculate_complexity(folder, files)
      await_results
      combine_results
    end

    private

    def calculate_complexity(folder, files)
      @complexity_results =
        if @complexity.folder_based?
          @complexity.calculate(folder:)
        else
          files.each_with_object({}) do |file, acc|
            acc.merge!(@complexity.calculate(file:))
          end
        end
    end

    def schedule_churn_calculation(folder, files, since)
      f = files.dup
      @threads = CONCURRENCY.times.map do
        t = Thread.new do
          until f.empty?
            next_file = f.pop
            @churn_results[next_file] = @churn.calculate(folder:, file: next_file, since:)
          end
        end
        t.report_on_exception = false
        t
      end
    end

    def await_results
      @threads.each(&:join)
    rescue StandardError => e
      raise Error, "Failed to caculate churn: #{e.message}"
    end

    def combine_results
      result = {}
      # TODO: filter out explicitly excluded files while not filtering out files that didn't churn
      result[:values_by_file] = @complexity_results.keys.each_with_object({}) do |file, acc|
        # File with complexity score might not have churned in queried period, 
        # set zero churn on miss
        acc[file] = [@churn_results[file] || 0, @complexity_results[file]]
      end
      result[:git_period] = @git_period
      result
    end
  end
end
