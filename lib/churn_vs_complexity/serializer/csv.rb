# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    module CSV
      def self.serialize(result)
        values_by_file = result[:values_by_file]
        values_by_file.map do |file, values|
          "#{file},#{values[0]},#{values[1]}\n"
        end.join
      end
    end
  end
end
