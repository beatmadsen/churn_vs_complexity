# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'tmpdir'

module ChurnVsComplexity
  class FocusAcceptanceTest < TLDR
    def setup
      @baseline_dir = Dir.mktmpdir('focus_test')
    end

    def teardown
      FileUtils.remove_entry(@baseline_dir) if @baseline_dir && Dir.exist?(@baseline_dir)
    end

    def test_focus_start_saves_baseline
      # Given: focus start mode targeting this repo
      config = Focus::Config.new(
        language: :ruby,
        subcommand: :start,
        since: '2000-01-01',
        baseline_path: File.join(@baseline_dir, '.focus-baseline.json'),
      )
      config.validate!

      # When: we run focus start
      result = config.checker.check(folder: '.')

      # Then: baseline file should exist with valid JSON
      baseline_path = File.join(@baseline_dir, '.focus-baseline.json')
      assert File.exist?(baseline_path), 'Baseline file should be created'

      baseline = JSON.parse(File.read(baseline_path))
      assert baseline.key?('timestamp'), 'Baseline should have a timestamp'
      assert baseline.key?('files'), 'Baseline should have files data'
      refute_empty baseline['files'], 'Baseline should contain file entries'

      # The start command should confirm what it did
      assert_match(/baseline saved/i, result)
    end

    def test_focus_end_produces_session_report
      # Given: a previously saved baseline (from focus start)
      baseline_path = File.join(@baseline_dir, '.focus-baseline.json')
      save_baseline(baseline_path)

      # And: focus end mode
      config = Focus::Config.new(
        language: :ruby,
        serializer: :json,
        subcommand: :end,
        since: '2000-01-01',
        baseline_path: baseline_path,
      )
      config.validate!

      # When: we run focus end
      result = config.checker.check(folder: '.')

      # Then: output should be a valid JSON session report
      parsed = JSON.parse(result)
      assert parsed.key?('session'), 'Should include session info'
      assert parsed['session'].key?('started'), 'Session should have start time'
      assert parsed['session'].key?('ended'), 'Session should have end time'

      assert parsed.key?('impact'), 'Should include impact summary'
      assert parsed['impact'].key?('mean_gamma_before'), 'Impact should have mean_gamma_before'
      assert parsed['impact'].key?('mean_gamma_after'), 'Impact should have mean_gamma_after'
      assert parsed['impact'].key?('direction'), 'Impact should have direction'

      assert parsed.key?('files_touched'), 'Should include files_touched array'
    end

    def test_focus_end_without_baseline_falls_back
      # Given: focus end mode with NO prior baseline
      nonexistent_path = File.join(@baseline_dir, '.focus-baseline.json')
      refute File.exist?(nonexistent_path), 'Precondition: no baseline file'

      config = Focus::Config.new(
        language: :ruby,
        serializer: :json,
        subcommand: :end,
        since: '2000-01-01',
        baseline_path: nonexistent_path,
      )
      config.validate!

      # When: we run focus end
      result = config.checker.check(folder: '.')

      # Then: it should still produce a report (with a warning)
      parsed = JSON.parse(result)
      assert parsed.key?('session'), 'Should still produce session info'
      assert parsed.key?('warning'), 'Should include a warning about missing baseline'
      assert_match(/no baseline/i, parsed['warning'])
    end

    private

    def save_baseline(path)
      # Run focus start to create a real baseline
      start_config = Focus::Config.new(
        language: :ruby,
        subcommand: :start,
        since: '2000-01-01',
        baseline_path: path,
      )
      start_config.validate!
      start_config.checker.check(folder: '.')
    end
  end
end
