# frozen_string_literal: true

require 'test_helper'

class DeltaIntegrationTest < TLDR
  def test_ruby_csv_completes
    config = ChurnVsComplexity::Delta::Config.new(
      language: :ruby,
      serializer: :summary,
      commits: ['b20a9bddd04afb9c7a736cf4530fd3188b5f785e', '4f3151f83e982eb8f2b8a4e7a7572a0af156c3c0'],
    )
    config.validate!
    result = config.checker.check(folder: 'lib')

    summary_file_path = File.join(ChurnVsComplexity::ROOT_PATH, 'tmp/test-support/delta/ruby-summary.txt')
    expected = File.read(summary_file_path)

    assert_equal expected, result
  end
end
