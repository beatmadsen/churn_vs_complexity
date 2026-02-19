# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'tmpdir'

module ChurnVsComplexity
  class EmptyFilesetAcceptanceTest < TLDR
    def setup
      @tmpdir = Dir.mktmpdir('empty_fileset_test')
      # Create a git repo with no Ruby files
      system('git', 'init', @tmpdir, out: File::NULL, err: File::NULL)
      File.write(File.join(@tmpdir, 'readme.txt'), 'not a ruby file')
      system('git', '-C', @tmpdir, 'add', '.', out: File::NULL, err: File::NULL)
      system('git', '-C', @tmpdir, 'commit', '-m', 'initial', out: File::NULL, err: File::NULL)
    end

    def teardown
      FileUtils.remove_entry(@tmpdir) if @tmpdir && Dir.exist?(@tmpdir)
    end

    def test_should_produce_valid_json_with_zeroed_summary_when_no_files_match_language
      # Given: Normal mode configured with --json for Ruby on a folder with no Ruby files
      config = Normal::Config.new(
        language: :ruby,
        serializer: :json,
        since: '2000-01-01',
      )
      config.validate!

      # When: we run the analysis against the empty-of-ruby-files repo
      result = config.checker.check(folder: @tmpdir)

      # Then: should produce valid JSON (not crash with ZeroDivisionError)
      parsed = JSON.parse(result)

      # And: files array should be empty
      assert_equal [], parsed['files'], 'Should have empty files array when no files match'

      # And: summary should have zeroed values
      summary = parsed['summary']
      assert_equal 0.0, summary['mean_churn'], 'mean_churn should be 0.0'
      assert_equal 0.0, summary['mean_complexity'], 'mean_complexity should be 0.0'
      assert_equal 0.0, summary['mean_gamma_score'], 'mean_gamma_score should be 0.0'
    end
  end
end
