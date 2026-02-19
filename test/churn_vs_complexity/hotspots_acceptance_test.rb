# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  class HotspotsAcceptanceTest < TLDR
    def test_should_produce_json_with_files_ranked_by_risk
      # Given: hotspots mode configured with JSON output for Ruby
      config = Hotspots::Config.new(
        language: :ruby,
        serializer: :json,
        since: '2000-01-01',
      )
      config.validate!

      # When: we run the hotspots analysis
      result = config.checker.check(folder: 'lib')

      # Then: the output should be valid JSON with risk-ranked files
      parsed = JSON.parse(result)

      assert parsed.key?('generated'), 'Should include generation timestamp'
      assert parsed.key?('files'), 'Should have files array'
      refute_empty parsed['files']

      # Files should be sorted by gamma_score descending (highest risk first)
      gamma_scores = parsed['files'].map { |f| f['gamma_score'] }
      assert_equal gamma_scores.sort.reverse, gamma_scores, 'Files should be sorted by gamma_score descending'

      first_file = parsed['files'].first
      assert first_file.key?('risk'), 'Each entry should have risk level'
      assert first_file.key?('gamma_score'), 'Each entry should have gamma_score'
      assert first_file.key?('churn'), 'Each entry should have churn'
      assert first_file.key?('complexity'), 'Each entry should have complexity'

      assert parsed.key?('summary'), 'Should have summary'
      summary = parsed['summary']
      assert summary.key?('high_risk'), 'Summary should count high_risk files'
      assert summary.key?('medium_risk'), 'Summary should count medium_risk files'
      assert summary.key?('low_risk'), 'Summary should count low_risk files'
    end
  end
end
