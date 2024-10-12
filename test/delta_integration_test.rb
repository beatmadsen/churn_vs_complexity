# frozen_string_literal: true

require 'test_helper'

class DeltaIntegrationTest < TLDR
  def test_ruby_csv_completes
    config = ChurnVsComplexity::Delta::Config.new(
      language: :ruby,
      serializer: :summary,
      commit: 'e75eb5aa',
    )
    config.validate!
    result = config.checker.check(folder: 'lib')
    assert_equal <<~EXPECTED, result
      File, relative path: lib/churn_vs_complexity/config.rb
      Type of change: modified
      Complexity: 70.26655854867414

      File, relative path: lib/churn_vs_complexity/serializer.rb
      Type of change: modified
      Complexity: 16.413256340277677

      File, relative path: lib/churn_vs_complexity/timetravel.rb
      Type of change: modified
      Complexity: 62.75918945702391

      File, relative path: lib/churn_vs_complexity/timetravel/traveller.rb
      Type of change: deleted
    EXPECTED
  end
end
