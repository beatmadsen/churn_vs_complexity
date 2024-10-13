# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    module Serializer
      def self.resolve(serializer)
        case serializer
        when :none
          Normal::Serializer::None
        when :csv
          CSV
        when :summary
          Summary
        when :pass_through
          PassThrough
        end
      end

      module CSV
        def self.serialize(result)
          changes = result[:changes]
          rows = ["Relative Path, Type of Change, Complexity\n"]
          changes.each do |change|
            rows << "#{change[:path]}, #{change[:type]}, #{change[:complexity]}\n"
          end
          rows.join
        end
      end

      module Summary
        class << self
          def serialize(result)
            changes = result[:changes]

            commit_text = "Commit:   #{result[:commit]}\nParent:   #{result[:parent]}\nNext:     #{result[:next_commit]}"
            change_text = changes.empty? ? '(No changes)' : describe(changes)

            "#{commit_text}\n\n\n#{change_text}"
          end

          def has_commit_summary? = true

          private

          def describe(changes)
            changes.map do |change|
              a = "File, relative path:  #{change[:path]}\nType of change:       #{change[:type]}\n"
              b = "Complexity:           #{change[:complexity]}\n" unless change[:complexity].nil?
              "#{a}#{b}"
            end.join("\n\n")
          end
        end
      end

      module PassThrough
        extend Normal::Serializer::None
        def self.has_commit_summary? = true
      end
    end
  end
end
