# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  module Hotspots
    class SerializerJsonTest < TLDR
      def test_should_use_language_specific_thresholds_in_hotspots_json
        # Given: a result with gamma ~30 and language: :ruby
        values_by_file = { 'lib/moderate.rb' => [30, 30.0] }
        # gamma = 30.0 → high with defaults, medium for Ruby
        result = { values_by_file:, language: :ruby }

        # When: serialize with hotspots JSON serializer
        output = Serializer::Json.serialize(result)
        parsed = JSON.parse(output)

        # Then: Ruby thresholds should classify gamma ~30 as NOT high
        ruby_risk = parsed['files'].first['risk']
        refute_equal 'high', ruby_risk,
                     "Gamma ~30 should not be high risk for Ruby in hotspots output"
      end

      def test_should_produce_sorted_json_with_risk_levels_and_timestamp
        # Given: a Normal-mode result with files of varying risk
        values_by_file = {
          'lib/low.rb' => [3, 2.0],
          'lib/high.rb' => [40, 30.0],
          'lib/medium.rb' => [15, 12.0],
        }
        end_date = Date.new(2024, 6, 15)
        git_period = Normal::Serializer::GitPeriod.new(requested_start_date: nil, end_date:)
        result = { values_by_file:, git_period: }

        # When: serialize with hotspots JSON serializer
        output = Serializer::Json.serialize(result)

        # Then: files should be sorted by gamma_score descending
        parsed = JSON.parse(output)
        gamma_scores = parsed['files'].map { |f| f['gamma_score'] }
        assert_equal gamma_scores.sort.reverse, gamma_scores, 'Files should be sorted highest risk first'

        assert parsed.key?('generated'), 'Should include generation timestamp'

        # Verify risk counts
        summary = parsed['summary']
        assert_equal 1, summary['high_risk']
        assert_equal 1, summary['medium_risk']
        assert_equal 1, summary['low_risk']
      end
    end
  end
end
