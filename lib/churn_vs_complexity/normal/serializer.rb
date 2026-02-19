# frozen_string_literal: true

require_relative 'serializer/summary_hash'
require_relative 'serializer/summary'
require_relative 'serializer/csv'
require_relative 'serializer/graph'
require_relative 'serializer/pass_through'
require_relative 'serializer/json'

module ChurnVsComplexity
  module Normal
    module Serializer
      def self.title(result)
        requested_start_date = result[:git_period].requested_start_date
        end_date = result[:git_period].end_date
        if requested_start_date.nil?
          "Churn until #{end_date.strftime('%Y-%m-%d')} vs complexity"
        else
          "Churn between #{requested_start_date.strftime('%Y-%m-%d')} and #{end_date.strftime('%Y-%m-%d')} vs complexity"
        end
      end

      module None
        extend self

        def serialize(result) = result
      end
    end
  end
end
