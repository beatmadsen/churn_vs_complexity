# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require 'json'

module ChurnVsComplexity
  module Focus
    class CheckerTest < TLDR
      def test_should_write_baseline_into_target_folder_when_path_is_relative
        # Given: a target folder and a relative baseline path
        target_dir = Dir.mktmpdir('focus_target')
        fake_engine = FakeEngine.new(values_by_file: { 'a.rb' => [1, 2] })

        checker = Checker.new(
          engine: fake_engine,
          subcommand: :start,
          serializer: nil,
          baseline_path: '.focus-baseline.json',
        )

        # When: check is called with the target folder
        checker.check(folder: target_dir)

        # Then: baseline should be written inside target_dir
        expected_path = File.join(target_dir, '.focus-baseline.json')
        assert File.exist?(expected_path), "Baseline should be written into #{target_dir}"
      ensure
        FileUtils.remove_entry(target_dir) if target_dir
      end

      private

      FakeEngine = Data.define(:values_by_file) do
        def check(folder:)
          { values_by_file: }
        end
      end
    end
  end
end
