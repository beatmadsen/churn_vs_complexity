# frozen_string_literal: true

module ChurnVsComplexity
  module Serializer
    module Summary
      def self.serialize(result)
        values_by_file = result[:values_by_file]
        summary = SummaryHash.serialize(result)

        <<~SUMMARY
          #{Serializer.title(result)}

          Number of observations: #{values_by_file.size}

          Churn:
          Mean #{summary[:mean_churn]}, Median #{summary[:median_churn]}

          Complexity:
          Mean #{summary[:mean_complexity]}, Median #{summary[:median_complexity]}

          Alpha score:
          Mean #{summary[:mean_alpha_score]}, Median #{summary[:median_alpha_score]}

          Beta score:
          Mean #{summary[:mean_beta_score]}, Median #{summary[:median_beta_score]}
        SUMMARY
      end
    end
  end
end
