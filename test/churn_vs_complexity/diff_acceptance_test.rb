# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  class DiffAcceptanceTest < TLDR
    def test_diff_produces_comparison_report
      # Given: diff mode comparing HEAD~3 against current
      config = Diff::Config.new(
        language: :ruby,
        serializer: :json,
        reference: 'HEAD~3',
        since: '2000-01-01',
      )
      config.validate!

      # When: we run the diff
      result = config.checker.check(folder: '.')

      # Then: output should be valid JSON with comparison structure
      parsed = JSON.parse(result)
      assert_equal 'HEAD~3', parsed['reference']
      assert_equal 'HEAD', parsed['current']

      assert parsed.key?('overall'), 'Should include overall summary'
      assert parsed['overall'].key?('mean_gamma_before'), 'Overall should have mean_gamma_before'
      assert parsed['overall'].key?('mean_gamma_after'), 'Overall should have mean_gamma_after'
      assert parsed['overall'].key?('direction'), 'Overall should have direction'

      assert parsed.key?('degraded'), 'Should include degraded files list'
      assert parsed.key?('improved'), 'Should include improved files list'
      assert parsed.key?('unchanged'), 'Should include unchanged count'

      assert_kind_of Array, parsed['degraded']
      assert_kind_of Array, parsed['improved']
      assert_kind_of Integer, parsed['unchanged']
    end

    def test_diff_degraded_files_have_expected_fields
      # Given: diff mode comparing an early commit against current
      config = Diff::Config.new(
        language: :ruby,
        serializer: :json,
        reference: 'HEAD~3',
        since: '2000-01-01',
      )
      config.validate!

      # When: we run the diff
      result = config.checker.check(folder: '.')
      parsed = JSON.parse(result)

      # Then: any degraded or improved file entries should have the expected shape
      changed = parsed['degraded'] + parsed['improved']
      return if changed.empty? # No changes between refs — not an error

      entry = changed.first
      assert entry.key?('file'), 'Entry should identify the file'
      assert entry.key?('gamma_before'), 'Entry should show gamma_before'
      assert entry.key?('gamma_after'), 'Entry should show gamma_after'
      assert entry.key?('change'), 'Entry should show percentage change'
    end
  end
end
