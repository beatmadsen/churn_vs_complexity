# frozen_string_literal: true

require 'test_helper'

class DeltaIntegrationTest < TLDR
  def test_ruby_csv_completes
    config = ChurnVsComplexity::Delta::Config.new(
      language: :ruby,
      serializer: :summary,
      commit: 'b20a9bddd04afb9c7a736cf4530fd3188b5f785e',
    )
    config.validate!
    result = config.checker.check(folder: 'lib')

    expected = <<~EXPECTED
      Commit:   b20a9bddd04afb9c7a736cf4530fd3188b5f785e
      Parent:   4f3151f83e982eb8f2b8a4e7a7572a0af156c3c0
      Next:     8cdaac516365bd7007b9f755bbe6f6e86d8e13dd


      File, relative path:  lib/churn_vs_complexity/serializer/timetravel.rb
      Type of change:       modified
      Complexity:           62.07689265062675


      File, relative path:  lib/churn_vs_complexity/serializer/timetravel/stats_calculator.rb
      Type of change:       deleted


      File, relative path:  test/churn_vs_complexity/serializer/timetravel/quality_calculator_test.rb
      Type of change:       modified
      Complexity:           13.054183368177016


      File, relative path:  test/churn_vs_complexity/serializer/timetravel/stats_calculator_test.rb
      Type of change:       deleted
    EXPECTED

    assert_equal expected, result
  end
end
