# frozen_string_literal: true

require 'test_helper'

class RubyIntegrationTest < TLDR
  def test_ruby_csv_completes
    config = ChurnVsComplexity::Normal::Config.new(
      language: :ruby,
      serializer: :csv,
      since: '2000-01-01',
    )
    config.validate!
    result = config.checker.check(folder: 'lib')
    refute_nil result
    refute_empty result
  end
end
