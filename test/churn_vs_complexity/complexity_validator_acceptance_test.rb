# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class ComplexityValidatorAcceptanceTest < TLDR
    def test_should_raise_error_when_python_tool_is_missing
      # Given: command runner simulates radon not found
      Complexity::PythonCalculator.command_runner = ->(*_args) { raise Errno::ENOENT }
      config = Normal::Config.new(
        language: :python,
        serializer: :csv,
        since: '2000-01-01',
      )

      # When/Then: validate! should raise because radon is not installed
      error = assert_raises(Error) { config.validate! }
      assert_match(/radon/i, error.message, 'Should mention radon in the error message')
    ensure
      Complexity::PythonCalculator.command_runner = nil
    end

    def test_should_raise_error_when_go_tool_is_missing
      # Given: command runner simulates gocognit not found
      Complexity::GoCalculator.command_runner = ->(*_args) { raise Errno::ENOENT }
      config = Normal::Config.new(
        language: :go,
        serializer: :csv,
        since: '2000-01-01',
      )

      # When/Then: validate! should raise because gocognit is not installed
      error = assert_raises(Error) { config.validate! }
      assert_match(/gocognit/i, error.message, 'Should mention gocognit in the error message')
    ensure
      Complexity::GoCalculator.command_runner = nil
    end
  end
end
