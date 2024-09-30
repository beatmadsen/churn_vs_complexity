# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    module Timetravel
      def self.summaries(result)
        result.sort_by do |_sha, summary|
          summary['end_date']
        end.map { |entry| entry[1] }
      end

      module CSV
        def self.serialize(result)
          summaries = Timetravel.summaries(result)

          # 2. Add title row to front of summaries
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
