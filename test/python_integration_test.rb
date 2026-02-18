# frozen_string_literal: true

require 'test_helper'

class PythonIntegrationTest < TLDR
  def test_python_csv_completes
    config = ChurnVsComplexity::Normal::Config.new(
      language: :python,
      serializer: :csv,
      since: '2000-01-01',
    )
    config.validate!
    result = config.checker.check(folder: 'tmp/test-support/python')
    refute_nil result
    refute_empty result
  end

  def test_should_calculate_real_complexity_scores_using_radon
    # Given: Python test files with known cyclomatic complexity
    #   example.py: hello(CC=1) + add(CC=1) = total 2
    #   utils.py:   calculate_sum(CC=2) + is_even(CC=1) = total 3
    test_files = [
      'tmp/test-support/python/example.py',
      'tmp/test-support/python/utils.py',
    ]

    # When: we calculate complexity
    result = ChurnVsComplexity::Complexity::PythonCalculator.calculate(files: test_files)

    # Then: scores should reflect real cyclomatic complexity, not stubs
    assert_equal 2, result['tmp/test-support/python/example.py'],
                 'example.py should have total complexity 2 (hello=1 + add=1)'
    assert_equal 3, result['tmp/test-support/python/utils.py'],
                 'utils.py should have total complexity 3 (calculate_sum=2 + is_even=1)'
  end
end
