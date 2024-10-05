# frozen_string_literal: true

require_relative 'timetravel/quality_calculator'

module ChurnVsComplexity
  module Serializer
    module Timetravel

      def mean(series)
        series.sum / series.size
      end

      def median(series)
        sorted = series.sort
        sorted[sorted.size / 2]        
      end

      # ['some_sha', { 'end_date' => '2024-01-01', 'values' => [[1, 2], [3, 4]] }]
      # TODO: quality sqores should be caluclated by file, not by sha. We will then aggregate them to mean and median quality scores for all files
      def self.summaries(result)
        observations =result.sort_by do |_sha, summary|
          summary['end_date']
        end.map { |entry| entry[1] }

        max_churn = observations.max_by { |o| o.dig('values', 0) }
        min_churn = observations.min_by { |o| o.dig('values', 0) }
        max_complexity = observations.max_by { |o| o.dig('values', 1) }
        min_complexity = observations.min_by { |o| o.dig('values', 1) }

        quality_calculator = QualityCalculator.new(
          min_churn: ,
          max_churn: ,
          min_complexity: ,
          max_complexity: ,
        )

        observations.map do |o|
          end_date = o['end_date']
          scores = o['values'].map do |churn, complexity|
            alpha = quality_calculator.alpha_score(churn, complexity)
            beta = quality_calculator.beta_score(churn, complexity)
            [churn, complexity, alpha, beta]
          end
          {
            'end_date' => end_date,
            'mean_churn' => mean(scores.map { |s| s[0] }),
            'median_churn' => median(scores.map { |s| s[0] }),
            'mean_complexity' => mean(scores.map { |s| s[1] }),
            'median_complexity' => median(scores.map { |s| s[1] }),
            'mean_alpha_score' => mean(scores.map { |s| s[2] }),
            'median_alpha_score' => median(scores.map { |s| s[2] }),
            'mean_beta_score' => mean(scores.map { |s| s[3] }),
            'median_beta_score' => median(scores.map { |s| s[3] }),
          }
        end
      end

      module CSV
        def self.serialize(result)
          summaries = Timetravel.summaries(result)

          # 2. Add title row to front of summaries
          # TODO: no longer alpha and beta scores, use gamma
          summaries.unshift(
            {
              'end_date' => 'Date',
              'mean_churn' => 'Mean Churn',
              'median_churn' => 'Median Churn',
              'mean_complexity' => 'Mean Complexity',
              'median_complexity' => 'Median Complexity',
              'mean_alpha_score' => 'Mean Alpha Score',
              'median_alpha_score' => 'Median Alpha Score',
              'mean_beta_score' => 'Mean Beta Score',
              'median_beta_score' => 'Median Beta Score',
            },
          )

          # 3. convert to csv
          summaries.map do |summary|
            "#{summary['end_date']},#{summary['mean_churn']},#{summary['median_churn']},#{summary['mean_complexity']},#{summary['median_complexity']},#{summary['mean_alpha_score']},#{summary['median_alpha_score']},#{summary['mean_beta_score']},#{summary['median_beta_score']}"
          end.join("\n")
        end
      end

      # TODO: unit test
      class Graph
        def initialize(git_period:, relative_period:, jump_days:, template: Graph.load_template_file)
          @template = template
          @git_period = git_period
          @relative_period = relative_period
          @jump_days = jump_days
        end

        def self.load_template_file
          file_path = File.expand_path('../../../tmp/template/timetravel_graph.html', __dir__)
          File.read(file_path)
        end

        def serialize(result)
          summaries = Timetravel.summaries(result)

          data = summaries.map do |summary|
            JSON.dump(summary)
          end.join(",\n") + "\n"

          @template.gsub("// INSERT DATA\n", data)
                   .gsub('INSERT TITLE', title)
                   .gsub('INSERT CHURN MODIFIER', churn_modifier)
        end

        private

        def title
          "#{churn_modifier}churn and complexity since #{since} evaluated every #{@jump_days} days"
        end

        def since
          if @git_period.requested_start_date.nil?
            'start of project'
          else
            @git_period.effective_start_date.strftime('%Y-%m-%d').to_s
          end
        end

        def churn_modifier
          case @relative_period
          when :month
            'Monthly '
          when :quarter
            'Quarterly '
          when :year
            'Yearly '
          else
            ''
          end
        end
      end
    end
  end
end
