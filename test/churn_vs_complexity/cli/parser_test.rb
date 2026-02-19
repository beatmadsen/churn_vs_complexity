# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module CLI
    class ParserTest < TLDR
      def test_should_parse_python_flag
        parser, options = Parser.create
        parser.parse!(['--python', '--csv', 'some_folder'])
        assert_equal :python, options[:language]
      end

      def test_should_parse_go_flag
        parser, options = Parser.create
        parser.parse!(['--go', '--csv', 'some_folder'])
        assert_equal :go, options[:language]
      end

      def test_should_parse_json_flag
        parser, options = Parser.create
        parser.parse!(['--ruby', '--json', 'some_folder'])
        assert_equal :json, options[:serializer]
      end

      def test_should_parse_triage_flag
        # Given/When: parse --triage
        parser, options = Parser.create
        parser.parse!(['--triage', '--ruby', '--json', 'lib', 'lib/foo.rb'])

        # Then: mode should be :triage
        assert_equal :triage, options[:mode]
      end
    end
  end
end
