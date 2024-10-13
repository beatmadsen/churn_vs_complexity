# frozen_string_literal: true

require 'test_helper'

class DeltaIntegrationTest < TLDR
  def test_ruby_csv_completes
    config = ChurnVsComplexity::Delta::Config.new(
      language: :ruby,
      serializer: :summary,
      commit: '8cdaac516365bd7007b9f755bbe6f6e86d8e13dd',
    )
    config.validate!
    result = config.checker.check(folder: 'lib')

    expected = "Commit: 8cdaac516365bd7007b9f755bbe6f6e86d8e13dd\nParent: b20a9bddd04afb9c7a736cf4530fd3188b5f785e\nNext: 29599743d3eab7d3926ded186336a861f1d00670\n\n\nFile, relative path: TODO\nType of change: modified\n\n\nFile, relative path: lib/churn_vs_complexity/serializer.rb\nType of change: modified\nComplexity: 16.413256340277677\n"

    assert_equal expected, result
  end
end
