# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  module Diff
    class SerializerTest < TLDR
      def test_should_classify_degraded_files
        # Given: a file whose gamma increased
        before = { values_by_file: { 'lib/foo.rb' => [10, 10.0] } }
        after = { values_by_file: { 'lib/foo.rb' => [20, 20.0] } }

        # When
        result = parse(before, after)

        # Then
        assert_equal 1, result['degraded'].size
        assert_empty result['improved']
        assert_equal 0, result['unchanged']
        assert_equal 'lib/foo.rb', result['degraded'].first['file']
      end

      def test_should_classify_improved_files
        # Given: a file whose gamma decreased
        before = { values_by_file: { 'lib/foo.rb' => [20, 20.0] } }
        after = { values_by_file: { 'lib/foo.rb' => [5, 5.0] } }

        # When
        result = parse(before, after)

        # Then
        assert_empty result['degraded']
        assert_equal 1, result['improved'].size
        assert_equal 'lib/foo.rb', result['improved'].first['file']
      end

      def test_should_count_unchanged_files
        # Given: a file with the same gamma
        before = { values_by_file: { 'lib/foo.rb' => [10, 10.0] } }
        after = { values_by_file: { 'lib/foo.rb' => [10, 10.0] } }

        # When
        result = parse(before, after)

        # Then
        assert_empty result['degraded']
        assert_empty result['improved']
        assert_equal 1, result['unchanged']
      end

      def test_should_compute_overall_direction_degraded
        # Given: mean gamma increased significantly
        before = { values_by_file: { 'a.rb' => [5, 5.0], 'b.rb' => [5, 5.0] } }
        after = { values_by_file: { 'a.rb' => [20, 20.0], 'b.rb' => [20, 20.0] } }

        # When
        result = parse(before, after)

        # Then
        assert_equal 'degraded', result['overall']['direction']
      end

      def test_should_compute_overall_direction_improved
        # Given: mean gamma decreased significantly
        before = { values_by_file: { 'a.rb' => [20, 20.0], 'b.rb' => [20, 20.0] } }
        after = { values_by_file: { 'a.rb' => [5, 5.0], 'b.rb' => [5, 5.0] } }

        # When
        result = parse(before, after)

        # Then
        assert_equal 'improved', result['overall']['direction']
      end

      def test_should_include_change_percentage
        # Given: a file with known gamma change
        before = { values_by_file: { 'lib/foo.rb' => [10, 10.0] } }
        after = { values_by_file: { 'lib/foo.rb' => [20, 20.0] } }

        # When
        result = parse(before, after)

        # Then
        entry = result['degraded'].first
        assert entry['change'].end_with?('%'), 'Change should be a percentage string'
        assert entry['change'].start_with?('+'), 'Degraded change should be positive'
      end

      def test_should_include_reference_and_current
        before = { values_by_file: {} }
        after = { values_by_file: {} }

        result = parse(before, after, reference: 'v1.0.0')

        assert_equal 'v1.0.0', result['reference']
        assert_equal 'HEAD', result['current']
      end

      def test_should_treat_files_only_in_one_snapshot_as_unchanged
        # Given: a file only in the after snapshot (new file)
        before = { values_by_file: {} }
        after = { values_by_file: { 'lib/new.rb' => [10, 10.0] } }

        # When
        result = parse(before, after)

        # Then: new files go to unchanged (no before gamma to compare)
        assert_empty result['degraded']
        assert_empty result['improved']
        assert_equal 1, result['unchanged']
      end

      private

      def parse(before, after, reference: 'HEAD~3')
        json = Serializer::Json.serialize(reference:, before:, after:)
        JSON.parse(json)
      end
    end
  end
end
