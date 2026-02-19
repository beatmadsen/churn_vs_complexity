# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  class JsonOutputAcceptanceTest < TLDR
    def test_should_produce_valid_json_with_per_file_data_when_using_json_serializer
      # Given: Normal mode configured with --json for Ruby on the lib folder
      config = Normal::Config.new(
        language: :ruby,
        serializer: :json,
        since: '2000-01-01',
      )
      config.validate!

      # When: we run the analysis
      result = config.checker.check(folder: 'lib')

      # Then: the output should be valid JSON with per-file data and summary
      parsed = JSON.parse(result)
      assert parsed.key?('files'), 'JSON output should contain a files array'
      assert parsed['files'].is_a?(Array), 'files should be an array'

      first_file = parsed['files'].first
      assert first_file.key?('file'), 'Each file entry should have a file path'
      assert first_file.key?('churn'), 'Each file entry should have churn'
      assert first_file.key?('complexity'), 'Each file entry should have complexity'
      assert first_file.key?('gamma_score'), 'Each file entry should have gamma_score'

      assert parsed.key?('summary'), 'JSON output should contain summary statistics'
      summary = parsed['summary']
      assert summary.key?('mean_churn'), 'Summary should include mean_churn'
      assert summary.key?('mean_complexity'), 'Summary should include mean_complexity'
      assert summary.key?('mean_gamma_score'), 'Summary should include mean_gamma_score'
    end
  end
end
