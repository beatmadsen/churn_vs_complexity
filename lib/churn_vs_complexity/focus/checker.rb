# frozen_string_literal: true

require 'json'

module ChurnVsComplexity
  module Focus
    class Checker
      def initialize(engine:, subcommand:, serializer:, baseline_path:)
        @engine = engine
        @subcommand = subcommand
        @serializer = serializer
        @baseline_path = baseline_path
      end

      def check(folder:)
        resolved_path = resolve_baseline_path(folder)
        case @subcommand
        when :start then run_start(folder, resolved_path)
        when :end then run_end(folder, resolved_path)
        end
      end

      private

      def run_start(folder, baseline_path)
        raw_result = @engine.check(folder:)
        entries = RiskAnnotator.annotate(raw_result[:values_by_file])

        baseline = {
          timestamp: Time.now.utc.iso8601,
          files: entries.map { |e| { file: e[:file], gamma_score: e[:gamma_score] } },
        }

        File.write(baseline_path, JSON.generate(baseline))
        "Baseline saved to #{baseline_path} (#{entries.size} files)"
      end

      def run_end(folder, baseline_path)
        raw_result = @engine.check(folder:)
        current_entries = RiskAnnotator.annotate(raw_result[:values_by_file])

        baseline = load_baseline(baseline_path)
        @serializer.serialize(baseline:, current: current_entries)
      end

      def load_baseline(baseline_path)
        return unless File.exist?(baseline_path)

        JSON.parse(File.read(baseline_path))
      end

      def resolve_baseline_path(folder)
        return @baseline_path if File.absolute_path?(@baseline_path)

        File.join(folder, @baseline_path)
      end
    end
  end
end
