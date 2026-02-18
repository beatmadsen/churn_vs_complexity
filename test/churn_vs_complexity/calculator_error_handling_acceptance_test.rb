# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class CalculatorErrorHandlingAcceptanceTest < TLDR
    FakeStatus = Data.define(:success?, :exitstatus)

    def test_should_raise_clear_error_when_gocognit_fails
      # Given: command runner simulates non-zero exit
      Complexity::GoCalculator.command_runner = ->(*_args) { ['', FakeStatus.new(false, 1)] }

      # When/Then: calculate should raise Error (not JSON::ParserError)
      error = assert_raises(Error) do
        Complexity::GoCalculator.calculate(files: ['main.go'])
      end
      assert_match(/gocognit failed/i, error.message,
                   'Should give a clear error about gocognit failure')
    ensure
      Complexity::GoCalculator.command_runner = nil
    end

    def test_should_raise_clear_error_when_radon_fails
      # Given: command runner simulates non-zero exit
      Complexity::PythonCalculator.command_runner = ->(*_args) { ['', FakeStatus.new(false, 1)] }

      # When/Then: calculate should raise Error (not JSON::ParserError)
      error = assert_raises(Error) do
        Complexity::PythonCalculator.calculate(files: ['any_file.py'])
      end
      assert_match(/radon failed/i, error.message,
                   'Should give a clear error about radon failure')
    ensure
      Complexity::PythonCalculator.command_runner = nil
    end
  end
end
