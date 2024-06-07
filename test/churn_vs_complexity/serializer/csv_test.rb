# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Serializer
    class CSVTest < TLDR
      def test_that_x
        values_by_file = {
          'file1' => [1, 1],
          'file2' => [2, 16],
        }
        result = CSV.serialize(values_by_file)
        assert_equal "file1,1,1\nfile2,2,16\n", result
      end
    end
  end
end
