# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  module Normal
    module Serializer
      class JsonTest < TLDR
        def test_should_produce_valid_json_with_per_file_data_and_summary
          # Given: a result hash with per-file values and git period
          values_by_file = {
            'lib/foo.rb' => [10, 5.0],
            'lib/bar.rb' => [20, 15.0],
          }
          end_date = Date.new(2024, 6, 15)
          git_period = GitPeriod.new(requested_start_date: nil, end_date:)
          result = { values_by_file:, git_period: }

          # When: we serialize as JSON
          output = Json.serialize(result)

          # Then: it should be valid JSON with files and summary
          parsed = JSON.parse(output)

          assert parsed.key?('files'), 'Should have files array'
          assert_equal 2, parsed['files'].size

          first = parsed['files'].find { |f| f['file'] == 'lib/foo.rb' }
          assert_equal 10, first['churn']
          assert_in_delta 5.0, first['complexity']
          assert first.key?('gamma_score'), 'Each file should have gamma_score'

          assert parsed.key?('summary'), 'Should have summary'
          assert parsed['summary'].key?('mean_churn')
          assert parsed['summary'].key?('mean_complexity')
          assert parsed['summary'].key?('mean_gamma_score')
        end
      end
    end
  end
end
