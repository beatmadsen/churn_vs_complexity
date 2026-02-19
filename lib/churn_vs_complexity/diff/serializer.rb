# frozen_string_literal: true

require 'json'

module ChurnVsComplexity
  module Diff
    module Serializer
      module Json
        def self.serialize(reference:, before:, after:)
          before_gammas = gammas_from(before)
          after_gammas = gammas_from(after)
          degraded, improved, unchanged_count = classify_changes(before_gammas, after_gammas)

          JSON.generate(
            reference:, current: 'HEAD',
            overall: overall_summary(before_gammas.values, after_gammas.values),
            degraded:, improved:, unchanged: unchanged_count,
          )
        end

        def self.gammas_from(result)
          result[:values_by_file].transform_values { |v| GammaScore.calculate(v[0], v[1]).round(2) }
        end

        def self.overall_summary(before_scores, after_scores)
          before_mean = mean(before_scores)
          after_mean = mean(after_scores)
          { mean_gamma_before: before_mean, mean_gamma_after: after_mean,
            direction: direction(before_mean, after_mean), }
        end

        def self.classify_changes(before_gammas, after_gammas)
          all_files = (before_gammas.keys + after_gammas.keys).uniq
          grouped = all_files.group_by { |f| classify_file(before_gammas[f], after_gammas[f]) }

          [
            entries_for(grouped[:degraded], before_gammas, after_gammas),
            entries_for(grouped[:improved], before_gammas, after_gammas),
            (grouped[:unchanged] || []).size,
          ]
        end

        def self.entries_for(files, before_gammas, after_gammas)
          (files || []).map { |f| file_entry(f, before_gammas[f], after_gammas[f]) }
        end

        def self.classify_file(old_g, new_g)
          return :unchanged if old_g.nil? || new_g.nil? || (old_g - new_g).abs < 0.01
          return :degraded if new_g > old_g

          :improved
        end

        def self.file_entry(file, old_g, new_g)
          pct = old_g.positive? ? (((new_g - old_g) / old_g) * 100).round(0) : 0
          sign = pct.positive? ? '+' : ''
          { file:, gamma_before: old_g, gamma_after: new_g, change: "#{sign}#{pct}%" }
        end

        def self.mean(scores)
          return 0.0 if scores.empty?

          (scores.sum.to_f / scores.size).round(2)
        end

        def self.direction(before, after)
          diff = after - before
          return 'unchanged' if diff.abs < 0.5

          diff.positive? ? 'degraded' : 'improved'
        end

        private_class_method :gammas_from, :overall_summary, :classify_changes,
                             :classify_file, :entries_for, :file_entry, :mean, :direction
      end
    end
  end
end
