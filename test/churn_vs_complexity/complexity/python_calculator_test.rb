# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Complexity
    class PythonCalculatorTest < TLDR
      FakeStatus = Data.define(:success?, :exitstatus)

      def test_should_not_be_folder_based
        refute PythonCalculator.folder_based?
      end

      def test_should_sum_per_function_complexity_from_radon_json
        # Given: radon JSON output with two functions for one file
        radon_json = JSON.generate({
          'app.py' => [
            { 'name' => 'foo', 'complexity' => 3 },
            { 'name' => 'bar', 'complexity' => 5 },
          ],
        })

        # When
        result = PythonCalculator.parse_radon_output(radon_json, files: ['app.py'])

        # Then: complexity should be sum of per-function scores
        assert_equal 8, result['app.py'],
                     'Should sum per-function complexity (3 + 5 = 8)'
      end

      def test_should_redirect_stderr_when_checking_dependencies
        # Given: a command runner that records what command was executed
        captured_command = nil
        PythonCalculator.command_runner = lambda { |cmd|
          captured_command = cmd
          ['', FakeStatus.new(true, 0)]
        }

        # When: check_dependencies! is called
        PythonCalculator.check_dependencies!

        # Then: the command should redirect stderr to suppress help text
        assert_match(/2>&1/, captured_command,
                     'check_dependencies! should redirect stderr to prevent radon output leaking')
      ensure
        PythonCalculator.command_runner = nil
      end

      def test_should_raise_error_when_radon_not_installed
        # Given: command runner that simulates tool not found
        PythonCalculator.command_runner = ->(*_args) { raise Errno::ENOENT }

        # When/Then: check_dependencies! should raise Error
        assert_raises(Error) { PythonCalculator.check_dependencies! }
      ensure
        PythonCalculator.command_runner = nil
      end

      def test_should_raise_error_when_radon_execution_fails
        # Given: command runner that returns non-zero exit status
        PythonCalculator.command_runner = ->(*_args) { ['', FakeStatus.new(false, 1)] }

        # When/Then: calculate should raise Error with clear message
        error = assert_raises(Error) do
          PythonCalculator.calculate(files: ['app.py'])
        end
        assert_match(/radon failed/i, error.message,
                     'Should mention radon failure in the error')
      ensure
        PythonCalculator.command_runner = nil
      end
    end
  end
end
