# frozen_string_literal: true

module ChurnVsComplexity
  module Hotspots
    class Checker
      def initialize(engine:, serializer:)
        @engine = engine
        @serializer = serializer
      end

      def check(folder:)
        raw_result = @engine.check(folder:)
        @serializer.serialize(raw_result)
      end
    end
  end
end
