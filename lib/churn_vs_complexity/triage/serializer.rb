# frozen_string_literal: true

require 'json'

module ChurnVsComplexity
  module Triage
    module Serializer
      module Json
        def self.serialize(result)
          entries = RiskAnnotator.annotate(result[:values_by_file])
          JSON.generate({ files: entries, summary: RiskAnnotator.risk_summary(entries) })
        end
      end
    end
  end
end
