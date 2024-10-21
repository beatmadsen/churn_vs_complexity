# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module CLI
    module Main
      class MainIntegrationTest < TLDR
        def test_run_raises_error_when_folder_is_nil
          error = assert_raises(ValidationError) do
            Main.run!(nil, nil)
          end
          assert_equal 'No folder selected. Use --help for usage information.', error.message
        end

        def test_run_raises_error_when_folder_is_empty
          error = assert_raises(ValidationError) do
            Main.run!(nil, '')
          end
          assert_equal 'No folder selected. Use --help for usage information.', error.message
        end

        def test_run_raises_error_when_folder_does_not_exist
          error = assert_raises(ValidationError) do
            Main.run!(nil, 'non_existent_folder')
          end
          assert_equal 'Folder non_existent_folder does not exist', error.message
        end

        def test_run_raises_error_when_no_options_are_selected
          Dir.mktmpdir do |dir|
            error = assert_raises(ValidationError) { Main.run!({}, dir) }
            assert_equal 'No options selected. Use --help for usage information.', error.message
          end
        end

        def test_run_raises_error_when_no_language_is_selected
          Dir.mktmpdir do |dir|
            error = assert_raises(ValidationError) { Main.run!({ a: 1}, dir) }
            assert_equal 'No language selected. Use --help for usage information.', error.message
          end
        end

        def test_run_raises_error_when_no_serializer_is_selected
          Dir.mktmpdir do |dir|
            error = assert_raises(ValidationError) { Main.run!({ language: 'ruby' }, dir) }
            assert_equal 'No serializer selected. Use --help for usage information.', error.message
          end
        end
      end
    end
  end
end
