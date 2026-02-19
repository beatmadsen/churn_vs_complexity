# frozen_string_literal: true

module ChurnVsComplexity
  module Hotspots
    class Checker
      def initialize(engine:, serializer:, language: nil)
        @engine = engine
        @serializer = serializer
        @language = language
      end

      def check(folder:)
        raw_result = @engine.check(folder:)
        @serializer.serialize(raw_result.merge(language: @language))
      end
    end
  end
end
