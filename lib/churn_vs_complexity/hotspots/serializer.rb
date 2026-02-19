# frozen_string_literal: true

require 'json'

module ChurnVsComplexity
  module Hotspots
    module Serializer
      module Json
        def self.serialize(result)
          entries = RiskAnnotator.annotate(result[:values_by_file], language: result[:language])
          entries.sort_by! { |e| -e[:gamma_score] }

          JSON.generate({ generated: Time.now.utc.iso8601, files: entries,
                          summary: RiskAnnotator.risk_summary(entries), })
        end
      end

      module Markdown
        RISK_HEADINGS = {
          'high' => 'High Risk -- require tests and careful review',
          'medium' => 'Medium Risk -- exercise judgement',
          'low' => 'Low Risk -- safe for quick changes',
        }.freeze

        def self.serialize(result)
          entries = RiskAnnotator.annotate(result[:values_by_file], language: result[:language])
          entries.sort_by! { |e| -e[:gamma_score] }
          grouped = entries.group_by { |e| e[:risk] }

          lines = ["## Hotspots (generated #{Date.today})", '']
          RISK_HEADINGS.each { |level, heading| append_section(lines, grouped[level], heading) }
          lines.join("\n")
        end

        def self.append_section(lines, entries, heading)
          return unless entries&.any?

          lines << "### #{heading}"
          entries.each do |e|
            lines << "- `#{e[:file]}` (gamma: #{e[:gamma_score]}, churn: #{e[:churn]}, complexity: #{e[:complexity]})"
          end
          lines << ''
        end

        private_class_method :append_section
      end
    end
  end
end
