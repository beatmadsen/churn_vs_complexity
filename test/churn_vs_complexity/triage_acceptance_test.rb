# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  class TriageAcceptanceTest < TLDR
    def test_should_produce_json_with_risk_levels_for_specified_directory
      # Given: triage mode configured with JSON output for Ruby on the lib folder
      config = Triage::Config.new(
        language: :ruby,
        serializer: :json,
        since: '2000-01-01',
        targets: ['lib'],
      )
      config.validate!

      # When: we run the triage analysis
      result = config.checker.check

      # Then: the output should be valid JSON with risk-annotated file data
      parsed = JSON.parse(result)

      assert parsed.key?('files'), 'Should have files array'
      assert parsed['files'].is_a?(Array), 'files should be an array'
      refute_empty parsed['files'], 'Should have at least one file'

      first_file = parsed['files'].first
      assert first_file.key?('file'), 'Each entry should have file path'
      assert first_file.key?('churn'), 'Each entry should have churn'
      assert first_file.key?('complexity'), 'Each entry should have complexity'
      assert first_file.key?('gamma_score'), 'Each entry should have gamma_score'
      assert first_file.key?('risk'), 'Each entry should have risk level'
      assert first_file.key?('recommendation'), 'Each entry should have recommendation'
      assert_includes %w[low medium high], first_file['risk'], 'Risk should be low, medium, or high'

      assert parsed.key?('summary'), 'Should have summary'
      summary = parsed['summary']
      assert summary.key?('high_risk'), 'Summary should count high_risk files'
      assert summary.key?('medium_risk'), 'Summary should count medium_risk files'
      assert summary.key?('low_risk'), 'Summary should count low_risk files'
    end
  end
end
