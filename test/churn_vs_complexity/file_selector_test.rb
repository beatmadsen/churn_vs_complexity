# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class FileSelectorTest < TLDR
    def test_should_return_py_extension_for_python
      result = FileSelector.extensions(:python)
      assert_equal ['.py'], result
    end

    def test_should_return_go_extension_for_go
      result = FileSelector.extensions(:go)
      assert_equal ['.go'], result
    end
  end
end
