# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    module Serializer
      def self.resolve(_serializer)
        case @serializer
        when :none
          Normal::Serializer::None
        when :csv
          Serializer::CSV
        when :summary
          Serializer::Summary
        end
      end

      module CSV
      end

      module Summary
      end
    end
  end
end
