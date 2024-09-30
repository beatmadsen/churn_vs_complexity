# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    module Timetravel
      module CSV
        def self.serialize(result)
          # result is a hash with sha keys and values are summary hashes

          # 1. convert to array of summaries sorted by date ascending
          summaries = result.sort_by do |sha, summary|
            summary['end_date']
          end.map { |entry| entry[1] }

          # 2. Add title row to front of summaries
          summaries.unshift({ 
            'end_date' => 'Date', 
            'mean_churn' => 'Mean Churn', 
            'median_churn' => 'Median Churn',
            'mean_complexity' => 'Mean Complexity',
            'median_complexity' => 'Median Complexity',
            'mean_product' => 'Mean Product',
            'median_product' => 'Median Product',
          })

          # 3. convert to csv          
          csv = summaries.map do |summary|
            "#{summary['end_date']},#{summary['mean_churn']},#{summary['median_churn']},#{summary['mean_complexity']},#{summary['median_complexity']},#{summary['mean_product']},#{summary['median_product']}"
          end.join("\n")

          csv
        end
      end

      module Graph
        def initialize(template: Graph.load_template_file)
          @template = template
        end

        def serialize(result)
        #   data = result[:values_by_file].map do |file, values|
        #     "{ file_path: '#{file}', churn: #{values[0]}, complexity: #{values[1]} }"
        #   end.join(",\n") + "\n"
        #   title = Serializer.title(result)
        #   @template.gsub("// INSERT DATA\n", data).gsub('INSERT TITLE', title)
          'Graph baby'
        end

        def self.load_template_file
          file_path = File.expand_path('../../tmp/template/timetravel_graph.html', __dir__)
          File.read(file_path)
        end
      end
    end
  end
end
