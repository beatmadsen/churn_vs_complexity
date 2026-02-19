# frozen_string_literal: true

require 'json'

module ChurnVsComplexity
  module Gate
    class Checker
      class Result
        def initialize(json, passed:)
          @json = json
          @passed = passed
        end

        def passed?
          @passed
        end

        def to_s
          @json
        end
      end

      def initialize(engine:, serializer:, max_gamma:)
        @engine = engine
        @serializer = serializer
        @max_gamma = max_gamma
      end

      def check(folder:)
        raw_result = @engine.check(folder:)
        json = @serializer.serialize(raw_result, max_gamma: @max_gamma)
        Result.new(json, passed: JSON.parse(json)['passed'])
      end
    end
  end
end
