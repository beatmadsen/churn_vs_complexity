# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Complexity
    class GoCalculatorTest < TLDR
      def test_should_not_be_folder_based
        refute GoCalculator.folder_based?
      end

      def test_should_sum_complexity_per_file_from_gocognit_json
        # Given: gocognit JSON output with functions from two files
        json_output = <<~JSON
          [
            {"PkgName":"main","FuncName":"main","Complexity":0,"Pos":{"Filename":"main.go","Offset":14,"Line":3,"Column":1}},
            {"PkgName":"main","FuncName":"add","Complexity":0,"Pos":{"Filename":"main.go","Offset":52,"Line":9,"Column":1}},
            {"PkgName":"main","FuncName":"calculateSum","Complexity":1,"Pos":{"Filename":"utils.go","Offset":14,"Line":3,"Column":1}},
            {"PkgName":"main","FuncName":"isEven","Complexity":0,"Pos":{"Filename":"utils.go","Offset":100,"Line":10,"Column":1}}
          ]
        JSON
        files = ['main.go', 'utils.go']

        # When: we parse the gocognit output
        result = GoCalculator.parse_gocognit_output(json_output, files:)

        # Then: complexity should be summed per file
        assert_equal 0, result['main.go'],
                     'main.go should have total complexity 0 (main=0 + add=0)'
        assert_equal 1, result['utils.go'],
                     'utils.go should have total complexity 1 (calculateSum=1 + isEven=0)'
      end

      def test_should_return_zero_for_files_with_no_functions
        # Given: gocognit returns empty array (no functions found)
        json_output = '[]'
        files = ['empty.go']

        # When: we parse the output
        result = GoCalculator.parse_gocognit_output(json_output, files:)

        # Then: file should have complexity 0
        assert_equal 0, result['empty.go'],
                     'File with no functions should have complexity 0'
      end

      def test_should_raise_error_when_gocognit_not_installed
        # Given: gocognit is not on PATH
        # When/Then: check_dependencies! should raise
        original_path = ENV['PATH']
        ENV['PATH'] = ''
        assert_raises(Error) { GoCalculator.check_dependencies! }
      ensure
        ENV['PATH'] = original_path
      end
    end
  end
end
