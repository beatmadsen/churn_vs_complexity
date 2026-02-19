# frozen_string_literal: true

require 'json'

module ChurnVsComplexity
  module Focus
    module Serializer
      module Json
        def self.serialize(baseline:, current:)
          baseline ? build_report(baseline, current) : build_fallback_report(current)
        end

        def self.build_report(baseline, current)
          before_gammas = baseline['files'].to_h { |f| [f['file'], f['gamma_score']] }
          after_gammas = current.to_h { |e| [e[:file], e[:gamma_score]] }
          touched = find_touched_files(before_gammas, after_gammas)

          JSON.generate(
            session: session_data(started: baseline['timestamp'], files_modified: touched.size),
            impact: impact_data(before: mean(before_gammas.values), after: mean(after_gammas.values)),
            files_touched: touched,
          )
        end

        def self.build_fallback_report(current)
          after_scores = current.map { |e| e[:gamma_score] }

          report = {
            warning: 'No baseline found. Comparing against current state only.',
            session: session_data(started: nil, files_modified: 0),
            impact: { mean_gamma_before: nil, mean_gamma_after: mean(after_scores), direction: 'unknown' },
            files_touched: [],
          }
          JSON.generate(report)
        end

        def self.session_data(started:, files_modified:)
          { started:, ended: Time.now.utc.iso8601, files_modified: }
        end

        def self.impact_data(before:, after:)
          { mean_gamma_before: before, mean_gamma_after: after, direction: direction(before, after) }
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

        def self.find_touched_files(before_files, after_files)
          all_files = (before_files.keys + after_files.keys).uniq
          all_files.filter_map { |file| build_touched_entry(file, before_files[file], after_files[file]) }
        end

        def self.build_touched_entry(file, old_gamma, new_gamma)
          return if old_gamma == new_gamma

          {
            file:,
            gamma_before: old_gamma, gamma_after: new_gamma,
            complexity_added: new_gamma ? (new_gamma - (old_gamma || 0)).round(2) : 0,
            has_tests: test_file_exists?(file),
            recommendation: recommend(old_gamma, new_gamma),
          }
        end

        def self.test_file_exists?(file)
          return false unless file

          base = File.basename(file, File.extname(file))
          ext = File.extname(file)
          %w[test spec].any? do |dir|
            File.exist?(File.join(dir, File.dirname(file), "#{base}_#{dir == 'test' ? 'test' : 'spec'}#{ext}"))
          end
        end

        def self.recommend(old_gamma, new_gamma)
          return 'File removed.' if new_gamma.nil?
          return 'New file. Add test coverage.' if old_gamma.nil?

          new_gamma > old_gamma ? 'Complexity increased. Consider adding tests.' : 'Complexity decreased. Good.'
        end

        private_class_method :build_report, :build_fallback_report, :session_data, :impact_data,
                             :mean, :direction, :find_touched_files, :build_touched_entry,
                             :test_file_exists?, :recommend
      end
    end
  end
end
