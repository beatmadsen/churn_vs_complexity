# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    module Serializer
      def self.resolve(serializer)
        case serializer
        when :none
          Normal::Serializer::None
        when :csv
          Serializer::CSV
        when :summary
          Serializer::Summary
        end
      end

      module CSV
        def self.serialize(changes)
          rows = ["Relative Path, Type of Change, Complexity\n"]
          changes.each do |change|
            rows << "#{change[:path]}, #{change[:type]}, #{change[:complexity]}\n"
          end
          rows.join
        end
      end

      module Summary
        def self.serialize(changes)
          changes.map do |change|
            a = "File, relative path: #{change[:path]}\nType of change: #{change[:type]}\n"
            b = "Complexity: #{change[:complexity]}" unless change[:complexity].nil?
            "#{a}#{b}"
          end.join("\n\n")
        end
      end
    end
  end
end
