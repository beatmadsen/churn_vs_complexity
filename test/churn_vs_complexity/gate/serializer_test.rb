# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  module Gate
    class SerializerJsonTest < TLDR
      def test_should_report_passed_when_all_files_below_threshold
        # Given: files with low gamma
        values_by_file = { 'lib/safe.rb' => [2, 1.0] }
        git_period = Normal::Serializer::GitPeriod.new(requested_start_date: nil, end_date: Date.new(2024, 1, 1))
        result = { values_by_file:, git_period: }

        # When: gate checks with high threshold
        output = Serializer::Json.serialize(result, max_gamma: 100)
        parsed = JSON.parse(output)

        # Then: should pass
        assert parsed['passed'], 'Should pass when no violations'
        assert_empty parsed['violations']
      end

      def test_should_report_failed_when_files_exceed_threshold
        # Given: a file with high gamma
        values_by_file = { 'lib/complex.rb' => [40, 30.0] }
        git_period = Normal::Serializer::GitPeriod.new(requested_start_date: nil, end_date: Date.new(2024, 1, 1))
        result = { values_by_file:, git_period: }

        # When: gate checks with low threshold
        output = Serializer::Json.serialize(result, max_gamma: 5)
        parsed = JSON.parse(output)

        # Then: should fail with violations
        refute parsed['passed'], 'Should fail when files exceed threshold'
        assert_equal 1, parsed['violations'].size
        assert_equal 'lib/complex.rb', parsed['violations'].first['file']
      end
    end
  end
end
