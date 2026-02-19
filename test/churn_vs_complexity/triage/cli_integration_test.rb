# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  module Triage
    class CLIIntegrationTest < TLDR
      def test_should_run_triage_through_cli_main
        # Given: options as CLI parser would produce
        options = { language: :ruby, mode: :triage, serializer: :json, excluded: [] }

        # When: run through CLI::Main
        result = CLI::Main.run!(options, 'lib')

        # Then: should produce valid JSON with risk levels
        parsed = JSON.parse(result)
        assert parsed.key?('files'), 'Should have files array'
        refute_empty parsed['files']

        first_file = parsed['files'].first
        assert first_file.key?('risk'), 'Each entry should have risk'
        assert_includes %w[low medium high], first_file['risk']
      end

      def test_should_not_require_serializer_flag_for_triage
        # Given: triage mode without explicit serializer
        options = { language: :ruby, mode: :triage, excluded: [] }

        # When/Then: should not raise validation error
        result = CLI::Main.run!(options, 'lib')
        parsed = JSON.parse(result)
        assert parsed.key?('files')
      end
    end
  end
end
