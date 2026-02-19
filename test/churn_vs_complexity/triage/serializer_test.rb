# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  module Triage
    class SerializerJsonTest < TLDR
      def test_should_produce_json_with_risk_levels_and_summary_counts
        # Given: a Normal-mode result hash
        values_by_file = {
          'lib/simple.rb' => [3, 2.0],
          'lib/complex.rb' => [40, 30.0],
          'lib/medium.rb' => [15, 12.0],
        }
        end_date = Date.new(2024, 6, 15)
        git_period = Normal::Serializer::GitPeriod.new(requested_start_date: nil, end_date:)
        result = { values_by_file:, git_period: }

        # When: we serialize with the triage JSON serializer
        output = Serializer::Json.serialize(result)

        # Then: output should be valid JSON with risk levels
        parsed = JSON.parse(output)

        files = parsed['files']
        assert_equal 3, files.size

        simple = files.find { |f| f['file'] == 'lib/simple.rb' }
        assert_equal 'low', simple['risk']
        assert simple.key?('recommendation')

        complex = files.find { |f| f['file'] == 'lib/complex.rb' }
        assert_equal 'high', complex['risk']

        summary = parsed['summary']
        assert_equal 1, summary['high_risk']
        assert_equal 1, summary['medium_risk']
        assert_equal 1, summary['low_risk']
      end
    end
  end
end
