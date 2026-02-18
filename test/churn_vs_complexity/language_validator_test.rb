# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class LanguageValidatorTest < TLDR
    def test_should_accept_python_as_a_valid_language
      LanguageValidator.validate!(:python)
    end

    def test_should_accept_go_as_a_valid_language
      LanguageValidator.validate!(:go)
    end
  end
end
