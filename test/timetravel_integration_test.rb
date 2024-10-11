# frozen_string_literal: true

require 'test_helper'

class TimetravelIntegrationTest < TLDR
  def test_ruby_csv_completes
    config = ChurnVsComplexity::Timetravel::Config.new(
      language: :ruby,
      serializer: :csv,
      jump_days: 3_000,
      relative_period: :month,
    )
    config.validate!
    result = config.checker.check(folder: ChurnVsComplexity::ROOT_PATH)
    refute_nil result
    refute_empty result
  end
end
