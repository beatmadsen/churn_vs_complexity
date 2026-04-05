# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Complexity
    class KotlinCalculatorTest < TLDR
      FakeStatus = Data.define(:success?, :exitstatus)

      def test_should_not_be_folder_based
        refute KotlinCalculator.folder_based?
      end

      def test_should_sum_complexity_per_file_from_lizard_csv
        # Given: lizard CSV output with functions from two Kotlin files
        csv_output = <<~CSV
          3,1,10,0,3,"main@1-3@Main.kt","Main.kt","main","main",1,3
          3,1,19,2,3,"add@5-7@Main.kt","Main.kt","add","add a : Int , b : Int",5,7
          7,2,31,1,7,"calculateSum@1-7@Utils.kt","Utils.kt","calculateSum","calculateSum numbers : List < Int >",1,7
          3,1,17,1,3,"isEven@9-11@Utils.kt","Utils.kt","isEven","isEven n : Int",9,11
        CSV
        files = ['Main.kt', 'Utils.kt']

        # When: we parse the lizard output
        result = KotlinCalculator.parse_lizard_output(csv_output, files:)

        # Then: complexity should be summed per file
        assert_equal 2, result['Main.kt'],
                     'Main.kt should have total complexity 2 (main=1 + add=1)'
        assert_equal 3, result['Utils.kt'],
                     'Utils.kt should have total complexity 3 (calculateSum=2 + isEven=1)'
      end

      def test_should_return_zero_for_files_with_no_functions
        # Given: lizard returns empty output (no functions found)
        csv_output = ''
        files = ['Empty.kt']

        # When: we parse the output
        result = KotlinCalculator.parse_lizard_output(csv_output, files:)

        # Then: file should have complexity 0
        assert_equal 0, result['Empty.kt'],
                     'File with no functions should have complexity 0'
      end

      def test_should_redirect_stderr_when_checking_dependencies
        # Given: a command runner that records what command was executed
        captured_command = nil
        KotlinCalculator.command_runner = lambda { |cmd|
          captured_command = cmd
          ['', FakeStatus.new(true, 0)]
        }

        # When: check_dependencies! is called
        KotlinCalculator.check_dependencies!

        # Then: the command should redirect stderr to suppress help text
        assert_match(/2>&1/, captured_command,
                     'check_dependencies! should redirect stderr to prevent lizard help text leaking',)
      ensure
        KotlinCalculator.command_runner = nil
      end

      def test_should_raise_error_when_lizard_not_installed
        # Given: command runner that simulates tool not found
        KotlinCalculator.command_runner = ->(*_args) { raise Errno::ENOENT }

        # When/Then: check_dependencies! should raise Error
        assert_raises(Error) { KotlinCalculator.check_dependencies! }
      ensure
        KotlinCalculator.command_runner = nil
      end

      def test_should_raise_error_when_lizard_execution_fails
        # Given: command runner that returns non-zero exit status
        KotlinCalculator.command_runner = ->(*_args) { ['', FakeStatus.new(false, 1)] }

        # When/Then: calculate should raise Error with clear message
        error = assert_raises(Error) do
          KotlinCalculator.calculate(files: ['Main.kt'])
        end
        assert_match(/lizard failed/i, error.message,
                     'Should mention lizard failure in the error',)
      ensure
        KotlinCalculator.command_runner = nil
      end
    end
  end
end
