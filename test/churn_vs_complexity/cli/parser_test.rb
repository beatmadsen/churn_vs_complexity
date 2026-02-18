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
    end
  end
end
