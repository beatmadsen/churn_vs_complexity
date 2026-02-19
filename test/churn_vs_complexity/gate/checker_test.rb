# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  module Gate
    class CheckerTest < TLDR
      def test_should_return_result_with_passed_true_when_no_violations
        # Given: a result with low gamma values
        values_by_file = { 'lib/safe.rb' => [2, 1.0] }
        git_period = Normal::Serializer::GitPeriod.new(requested_start_date: nil, end_date: Date.new(2024, 1, 1))
        raw_result = { values_by_file:, git_period: }

        fake_engine = FakeEngine.new(raw_result)
        checker = Checker.new(engine: fake_engine, serializer: Serializer::Json, max_gamma: 100)

        # When
        result = checker.check(folder: '.')

        # Then: Result object should indicate passed
        assert result.passed?, 'Should pass when no violations'

        # And: JSON should also reflect this
        parsed = JSON.parse(result.to_s)
        assert parsed['passed'], 'JSON should report passed'
        assert_empty parsed['violations']
      end

      def test_should_return_result_with_passed_false_when_violations_exist
        # Given: a result with high gamma values
        values_by_file = { 'lib/complex.rb' => [40, 30.0] }
        git_period = Normal::Serializer::GitPeriod.new(requested_start_date: nil, end_date: Date.new(2024, 1, 1))
        raw_result = { values_by_file:, git_period: }

        fake_engine = FakeEngine.new(raw_result)
        checker = Checker.new(engine: fake_engine, serializer: Serializer::Json, max_gamma: 5)

        # When
        result = checker.check(folder: '.')

        # Then: Result object should indicate failed
        refute result.passed?, 'Should fail when violations exist'

        # And: JSON should also reflect this
        parsed = JSON.parse(result.to_s)
        refute parsed['passed'], 'JSON should report failed'
        refute_empty parsed['violations']
      end

      class FakeEngine
        def initialize(result)
          @result = result
        end

        def check(folder:)
          @result
        end
      end
    end
  end
end
