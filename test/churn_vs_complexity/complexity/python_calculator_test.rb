# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Complexity
    class PythonCalculatorTest < TLDR
      def test_should_not_be_folder_based
        refute PythonCalculator.folder_based?
      end

      def test_should_sum_per_function_complexity_from_radon_json
        # Given: radon JSON output with two functions for one file
        radon_json = JSON.generate({
          'app.py' => [
            { 'name' => 'foo', 'complexity' => 3 },
            { 'name' => 'bar', 'complexity' => 5 },
          ],
        })

        # When
        result = PythonCalculator.parse_radon_output(radon_json, files: ['app.py'])

        # Then: complexity should be sum of per-function scores
        assert_equal 8, result['app.py'],
                     'Should sum per-function complexity (3 + 5 = 8)'
      end
    end
  end
end
