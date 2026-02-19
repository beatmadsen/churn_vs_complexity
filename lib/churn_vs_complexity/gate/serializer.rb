# frozen_string_literal: true

require 'json'

module ChurnVsComplexity
  module Gate
    module Serializer
      module Json
        class << self
          def serialize(result, max_gamma:)
            violations = find_violations(result[:values_by_file], max_gamma)

            JSON.generate(
              passed: violations.empty?,
              threshold: { max_gamma: },
              violations:,
            )
          end

          private

          def find_violations(values_by_file, max_gamma)
            values_by_file.filter_map do |file, values|
              gamma = GammaScore.calculate(values[0], values[1]).round(2)
              next unless gamma > max_gamma

              exceeds_pct = (((gamma - max_gamma) / max_gamma) * 100).round(0)
              { file:, gamma_score: gamma, exceeds_by: "#{exceeds_pct}%" }
            end
          end
        end
      end
    end
  end
end
