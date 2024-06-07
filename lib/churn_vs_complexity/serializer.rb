# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    module None
      def self.serialize(values_by_file) = values_by_file
    end

    module CSV
      def self.serialize(values_by_file)
        values_by_file.map do |file, values|
          "#{file},#{values[0]},#{values[1]}\n"
        end.join
      end
    end

    class Graph
      def initialize(title:, template: Graph.load_template_file)
        @template = template
        @title = title
      end

      def serialize(values_by_file)
        data = values_by_file.map do |file, values|
          "{ file_path: '#{file}', churn: #{values[0]}, complexity: #{values[1]} }"
        end.join(",\n") + "\n"
        @template.gsub("// INSERT DATA\n", data).gsub('INSERT TITLE', @title)
      end

      def self.load_template_file
        file_path = File.expand_path('../../tmp/template/graph.html', __dir__)
        File.read(file_path)
      end
    end
  end
end
