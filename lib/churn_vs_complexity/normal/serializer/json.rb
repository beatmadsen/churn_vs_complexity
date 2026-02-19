# frozen_string_literal: true

require 'json'

module ChurnVsComplexity
  module Normal
    module Serializer
      module Json
        class << self
          def serialize(result)
            values_by_file = result[:values_by_file]
            summary = SummaryHash.serialize(result)

            files = values_by_file.map { |file, values| build_file_entry(file, values) }

            JSON.generate({
                            files:,
                            summary: summary.merge(end_date: summary[:end_date].to_s),
                          })
          end

          private

          def build_file_entry(file, values)
            {
              file:,
              churn: values[0],
              complexity: values[1].to_f,
              gamma_score: GammaScore.calculate(values[0], values[1]).round(2),
            }
          end
        end
      end
    end
  end
end
