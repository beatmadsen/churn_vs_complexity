# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class EngineTest < TLDR
    def test_that_it_uses_the_serializer
      serializer = Serializer::Mock.new

      Engine.new(
        serializer:,
        calculator: CalculatorStub,
        file_selector: FileSelector::Stub,
        since: Date.new(2012, 2, 2),
      ).check(folder: 'folder')

      assert_equal({ 'file1' => [1, 1], 'file2' => [1, 1] }, serializer.serialize_called_with)
    end

    def test_that_it_calcualtes_the_complexity_and_churn_for_selected_files
      result = Engine.new(
        serializer: Normal::Serializer::None,
        calculator: CalculatorStub,
        file_selector: FileSelector::Stub,
        since: Date.new(2012, 2, 2),
      ).check(folder: 'folder')

      assert_equal({ 'file1' => [1, 1], 'file2' => [1, 1] }, result)
    end
  end

  class CalculatorStub
    def self.calculate(files:, folder:, since:)
      files.to_h { |file| [file, [1, 1]] }
    end
  end

  module FileSelector
    class Stub
      def self.select_files(_folder)
        %w[file1 file2]
      end
    end
  end

  module Serializer
    class Mock
      attr_reader :serialize_called_with

      def serialize(values_by_file)
        @serialize_called_with = values_by_file
        values_by_file
      end
    end
  end
end
