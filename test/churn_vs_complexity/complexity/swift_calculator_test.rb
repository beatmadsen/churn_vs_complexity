# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Complexity
    class SwiftCalculatorTest < TLDR
      FakeStatus = Data.define(:success?, :exitstatus)

      def test_should_not_be_folder_based
        refute SwiftCalculator.folder_based?
      end

      def test_should_sum_complexity_per_file_from_lizard_csv
        # Given: lizard CSV output with functions from two Swift files
        csv_output = <<~CSV
          3,1,10,0,3,"main()@1-3@main.swift","main.swift","main","main",1,3
          3,1,12,2,3,"add(_:_:)@5-7@main.swift","main.swift","add","add _ a : Int , _ b : Int",5,7
          7,3,31,1,7,"calculateSum(_:)@1-7@utils.swift","utils.swift","calculateSum","calculateSum _ numbers : [ Int ]",1,7
          10,4,50,1,10,"classify(_:)@9-18@utils.swift","utils.swift","classify","classify _ value : Int",9,18
          3,1,17,1,3,"isEven(_:)@20-22@utils.swift","utils.swift","isEven","isEven _ n : Int",20,22
        CSV
        files = ['main.swift', 'utils.swift']

        # When: we parse the lizard output
        result = SwiftCalculator.parse_lizard_output(csv_output, files:)

        # Then: complexity should be summed per file
        assert_equal 2, result['main.swift'],
                     'main.swift should have total complexity 2 (main=1 + add=1)'
        assert_equal 8, result['utils.swift'],
                     'utils.swift should have total complexity 8 (calculateSum=3 + classify=4 + isEven=1)'
      end

      def test_should_return_zero_for_files_with_no_functions
        # Given: lizard returns empty output (no functions found)
        csv_output = ''
        files = ['empty.swift']

        # When: we parse the output
        result = SwiftCalculator.parse_lizard_output(csv_output, files:)

        # Then: file should have complexity 0
        assert_equal 0, result['empty.swift'],
                     'File with no functions should have complexity 0'
      end

      def test_should_redirect_stderr_when_checking_dependencies
        # Given: a command runner that records what command was executed
        captured_command = nil
        SwiftCalculator.command_runner = lambda { |cmd|
          captured_command = cmd
          ['', FakeStatus.new(true, 0)]
        }

        # When: check_dependencies! is called
        SwiftCalculator.check_dependencies!

        # Then: the command should redirect stderr to suppress help text
        assert_match(/2>&1/, captured_command,
                     'check_dependencies! should redirect stderr to prevent lizard help text leaking',)
      ensure
        SwiftCalculator.command_runner = nil
      end

      def test_should_raise_error_when_lizard_not_installed
        # Given: command runner that simulates tool not found
        SwiftCalculator.command_runner = ->(*_args) { raise Errno::ENOENT }

        # When/Then: check_dependencies! should raise Error
        assert_raises(Error) { SwiftCalculator.check_dependencies! }
      ensure
        SwiftCalculator.command_runner = nil
      end

      def test_should_raise_error_when_lizard_execution_fails
        # Given: command runner that returns non-zero exit status
        SwiftCalculator.command_runner = ->(*_args) { ['', FakeStatus.new(false, 1)] }

        # When/Then: calculate should raise Error with clear message
        error = assert_raises(Error) do
          SwiftCalculator.calculate(files: ['main.swift'])
        end
        assert_match(/lizard failed/i, error.message,
                     'Should mention lizard failure in the error',)
      ensure
        SwiftCalculator.command_runner = nil
      end
    end
  end
end
