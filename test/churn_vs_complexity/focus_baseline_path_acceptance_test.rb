# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'tmpdir'

module ChurnVsComplexity
  class FocusBaselinePathAcceptanceTest < TLDR
    dont_run_these_in_parallel!

    def setup
      @target_dir = Dir.mktmpdir('focus_target')
      @cwd_dir = Dir.mktmpdir('focus_cwd')

      # Create a git repo with a Ruby file in the target dir
      system('git', 'init', @target_dir, out: File::NULL, err: File::NULL)
      File.write(File.join(@target_dir, 'app.rb'), 'class App; end')
      system('git', '-C', @target_dir, 'add', '.', out: File::NULL, err: File::NULL)
      system('git', '-C', @target_dir, 'commit', '-m', 'initial', out: File::NULL, err: File::NULL)
    end

    def teardown
      FileUtils.remove_entry(@target_dir) if @target_dir && Dir.exist?(@target_dir)
      FileUtils.remove_entry(@cwd_dir) if @cwd_dir && Dir.exist?(@cwd_dir)
    end

    def test_should_write_baseline_into_target_folder_not_cwd
      # Given: focus start with default (relative) baseline path, run from a different CWD
      config = Focus::Config.new(
        language: :ruby,
        subcommand: :start,
        since: '2000-01-01',
      )
      config.validate!

      # When: we run focus start from a CWD that differs from the target folder
      Dir.chdir(@cwd_dir) do
        config.checker.check(folder: @target_dir)
      end

      # Then: baseline should be in the target folder
      expected_path = File.join(@target_dir, '.focus-baseline.json')
      assert File.exist?(expected_path),
             "Baseline should be written into target folder (#{@target_dir}), not CWD"

      # And: baseline should NOT be in the CWD
      wrong_path = File.join(@cwd_dir, '.focus-baseline.json')
      refute File.exist?(wrong_path),
             "Baseline should NOT be written to CWD (#{@cwd_dir})"

      # And: the baseline should contain valid JSON with file data
      baseline = JSON.parse(File.read(expected_path))
      assert baseline.key?('files'), 'Baseline should have files data'
    end
  end
end
