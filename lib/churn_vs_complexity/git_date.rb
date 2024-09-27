# frozen_string_literal: true

module ChurnVsComplexity
  module GitDate

    def self.select_dates_with_at_least_interval(dates, interval)
      ds = dates.sort
      ds.each_with_object([]) do |date, acc|
        if acc.empty? || date - acc.last >= interval
          acc << date
        end
      end
    end

    def self.git_period(cli_arg_since, latest_commit_date)
      latest_commit_date = latest_commit_date.to_date
      if cli_arg_since.nil?
        NoStartGitPeriod.new(latest_commit_date)
      elsif cli_arg_since.is_a?(Symbol)
        AbsoluteGitPeriod.looking_back(relative_period: cli_arg_since, from: latest_commit_date)
      elsif cli_arg_since.is_a?(String)
        AbsoluteGitPeriod.between(cli_arg_since, latest_commit_date)
      else
        raise Error, "Unexpected since value #{cli_arg_since}"
      end
    end

    class NoStartGitPeriod
      attr_reader :end_date

      def initialize(end_date)
        @end_date = end_date
      end

      def effective_start_date = Time.at(0).to_date

      def requested_start_date = nil
    end

    class AbsoluteGitPeriod
      attr_reader :end_date

      def self.between(cli_arg_since, latest_commit_date)
        start_date = Date.strptime(cli_arg_since, '%Y-%m-%d')
        new(start_date, latest_commit_date)
      end

      def self.looking_back(relative_period:, from:)
        shifter = case relative_period
                  when :month then 1
                  when :quarter then 3
                  when :year then 12
                  else raise Error, "Unexpected since value #{relative_period}"
                  end
        start_date = from << shifter
        new(start_date, from)
      end

      def initialize(start_date, end_date)
        @start_date = start_date
        @end_date = end_date
      end

      def effective_start_date = @start_date

      def requested_start_date = @start_date
    end
  end
end
