# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Delta
    class CheckerTest < TLDR
      def test_check
        factory = FactoryStub.new
        result = checker(factory:).check(folder: 'space-place')
        assert_equal 'yo', result
      end

      private

      def checker(factory: FactoryStub.new, serializer: Normal::Serializer::None, excluded: [])
        Checker.new(factory:, serializer:, excluded:)
      end
    end

    class FactoryStub
      F = Factory
      delegate :complexity_validator, to: F
    end
  end
end
