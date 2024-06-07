# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Serializer
    class GraphTest < TLDR
      def test_that_it_renders_template
        values_by_file = {
          'file1' => [1, 1],
          'file2' => [2, 16],
        }
        serializer = Graph.new(title: 'My Title',
                               template: "TEMPLATE BEGIN\n<title>INSERT TITLE</title>\nINSERT TITLE\n// INSERT DATA\nTEMPLATE END",)

        result = serializer.serialize(values_by_file)

        expected = <<~EXPECTED.strip
          TEMPLATE BEGIN
          <title>My Title</title>
          My Title
          { file_path: 'file1', churn: 1, complexity: 1 },
          { file_path: 'file2', churn: 2, complexity: 16 }
          TEMPLATE END
        EXPECTED

        assert_equal expected, result
      end
    end
  end
end
