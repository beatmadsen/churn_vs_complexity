# frozen_string_literal: true

module ChurnVsComplexity
  module Normal
    module Serializer
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
          file_path = File.join(ROOT_PATH, 'tmp/template/graph.html')
          File.read(file_path)
        end
      end
    end
  end
end
