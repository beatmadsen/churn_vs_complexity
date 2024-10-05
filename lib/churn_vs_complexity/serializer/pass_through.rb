# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    module PassThrough
      class << self
        def serialize(result)
          values_by_file = result[:values_by_file]
          end_date = result[:git_period].end_date
          values = values_by_file.map do |_, values|
            [values[0].to_f, values[1].to_f]
          end
          {
            end_date:,
            values:,
          }
        end
      end
    end
  end
end
