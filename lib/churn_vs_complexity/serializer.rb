# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    def self.title(result)
      requested_start_date = result[:git_period].requested_start_date
      end_date = result[:git_period].end_date
      if requested_start_date.nil?
        "Churn until #{end_date.strftime('%Y-%m-%d')} vs complexity"
      else
        "Churn between #{requested_start_date.strftime('%Y-%m-%d')} and #{end_date.strftime('%Y-%m-%d')} vs complexity"
      end
    end

    module None
      def self.serialize(result) = result
    end

    module SummaryHash
      def self.serialize(result)
        values_by_file = result[:values_by_file]
        churn_values = values_by_file.map { |_, values| values[0].to_f }
        complexity_values = values_by_file.map { |_, values| values[1].to_f }

        mean_churn = churn_values.sum / churn_values.size
        median_churn = churn_values.sort[churn_values.size / 2]
        mean_complexity = complexity_values.sum / complexity_values.size
        median_complexity = complexity_values.sort[complexity_values.size / 2]

        product = values_by_file.map { |_, values| values[0].to_f * values[1].to_f }
        mean_product = product.sum / product.size
        median_product = product.sort[product.size / 2]
        
        end_date = result[:git_period].end_date

        {
          mean_churn:,
          median_churn:,
          mean_complexity:,
          median_complexity:,
          mean_product:,
          median_product:,
          end_date:,
        }
      end
    end

    module Summary
      def self.serialize(result)
        values_by_file = result[:values_by_file]
        summary = SummaryHash.serialize(result)

        <<~SUMMARY
          #{Serializer.title(result)}

          Number of observations: #{values_by_file.size}

          Churn:
          Mean #{summary[:mean_churn]}, Median #{summary[:median_churn]}

          Complexity:
          Mean #{summary[:mean_complexity]}, Median #{summary[:median_complexity]}

          Product of churn and complexity:
          Mean #{summary[:mean_product]}, Median #{summary[:median_product]}
        SUMMARY
      end
    end

    module CSV
      def self.serialize(result)
        values_by_file = result[:values_by_file]
        values_by_file.map do |file, values|
          "#{file},#{values[0]},#{values[1]}\n"
        end.join
      end
    end

    class Graph
      def initialize(template: Graph.load_template_file)
        @template = template
      end

      def serialize(result)
        data = result[:values_by_file].map do |file, values|
          "{ file_path: '#{file}', churn: #{values[0]}, complexity: #{values[1]} }"
        end.join(",\n") + "\n"
        title = Serializer.title(result)
        @template.gsub("// INSERT DATA\n", data).gsub('INSERT TITLE', title)
      end

      def self.load_template_file
        file_path = File.expand_path('../../tmp/template/graph.html', __dir__)
        File.read(file_path)
      end
    end
  end
end
