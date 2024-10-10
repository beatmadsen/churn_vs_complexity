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
        serializer = Graph.new(template: "TEMPLATE BEGIN\n<title>INSERT TITLE</title>\nINSERT TITLE\n// INSERT DATA\nTEMPLATE END")

        git_period = GitPeriod.new(requested_start_date: Date.new(2023, 1, 1),
                                   end_date: Date.new(2024, 1, 1),)
        result = serializer.serialize({ values_by_file:, git_period: })

        expected = <<~EXPECTED.strip
          TEMPLATE BEGIN
          <title>Churn between 2023-01-01 and 2024-01-01 vs complexity</title>
          Churn between 2023-01-01 and 2024-01-01 vs complexity
          { file_path: 'file1', churn: 1, complexity: 1 },
          { file_path: 'file2', churn: 2, complexity: 16 }
          TEMPLATE END
        EXPECTED

        assert_equal expected, result
      end
    end
  end
end
