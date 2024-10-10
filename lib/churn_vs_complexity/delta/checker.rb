# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class Checker
      def initialize(serializer:)
        @serializer = serializer
      end

      def check(folder:); end
    end
  end
end
