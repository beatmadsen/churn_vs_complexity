# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class ComplexityValidatorTest < TLDR
    def test_should_call_python_check_dependencies_when_language_is_python
      # Given: command runner simulates tool not found
      Complexity::PythonCalculator.command_runner = ->(*_args) { raise Errno::ENOENT }

      # When/Then: validate! should raise Error for :python
      assert_raises(Error) { ComplexityValidator.validate!(:python) }
    ensure
      Complexity::PythonCalculator.command_runner = nil
    end

    def test_should_call_go_check_dependencies_when_language_is_go
      # Given: command runner simulates tool not found
      Complexity::GoCalculator.command_runner = ->(*_args) { raise Errno::ENOENT }

      # When/Then: validate! should raise Error for :go
      assert_raises(Error) { ComplexityValidator.validate!(:go) }
    ensure
      Complexity::GoCalculator.command_runner = nil
    end
  end
end
