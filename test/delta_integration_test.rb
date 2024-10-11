# frozen_string_literal: true

require 'test_helper'

class DeltaIntegrationTest < TLDR
  def test_ruby_csv_completes
    config = ChurnVsComplexity::Delta::Config.new(
      language: :ruby,
      serializer: :csv,
      commit: 'e75eb5aa',
    )
    config.validate!
    result = config.checker.check(folder: 'lib')
    refute_nil result
    refute_empty result
  end
end
