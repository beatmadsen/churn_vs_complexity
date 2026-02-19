# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  class GateAcceptanceTest < TLDR
    def test_should_pass_when_no_files_exceed_threshold
      # Given: gate mode with a very high threshold (all files should pass)
      config = Gate::Config.new(
        language: :ruby,
        serializer: :json,
        since: '2000-01-01',
        max_gamma: 999,
      )
      config.validate!

      # When: we run the gate check
      result = config.checker.check(folder: 'lib')

      # Then: gate should pass (Result object and JSON)
      assert result.passed?, 'Gate should pass when no files exceed threshold'
      parsed = JSON.parse(result.to_s)
      assert parsed['passed'], 'JSON should report passed'
      assert_equal 999, parsed['threshold']['max_gamma']
      assert parsed.key?('violations'), 'Should include violations array (empty)'
      assert_empty parsed['violations'], 'No violations expected'
    end

    def test_should_fail_when_files_exceed_threshold
      # Given: gate mode with a very low threshold (some files should fail)
      # NOTE: folder must be '.' (git root) so churn is calculated correctly
      config = Gate::Config.new(
        language: :ruby,
        serializer: :json,
        since: '2000-01-01',
        max_gamma: 0.001,
      )
      config.validate!

      # When: we run the gate check from the git root
      result = config.checker.check(folder: '.')

      # Then: gate should fail with violations
      refute result.passed?, 'Gate should fail when files exceed threshold'
      parsed = JSON.parse(result.to_s)
      refute_empty parsed['violations'], 'Should list violating files'

      violation = parsed['violations'].first
      assert violation.key?('file'), 'Violation should identify the file'
      assert violation.key?('gamma_score'), 'Violation should show gamma_score'
    end
  end
end
