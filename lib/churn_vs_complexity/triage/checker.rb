# frozen_string_literal: true

module ChurnVsComplexity
  module Triage
    class Checker
      def initialize(language:, serializer:, targets:, since:, excluded:)
        @language = language
        @serializer = serializer
        @targets = targets
        @since = since
        @excluded = excluded
      end

      def check(folder: nil)
        files, dirs = partition_targets
        folder = folder || dirs.first || '.'
        engine = build_engine(files, folder)
        raw_result = engine.check(folder:)
        @serializer.serialize(raw_result.merge(language: @language))
      end

      private

      def partition_targets
        @targets.partition { |t| File.file?(t) }
      end

      def build_engine(files, _folder)
        Engine.concurrent(
          complexity: complexity_for(@language),
          churn: Churn::GitCalculator,
          file_selector: select_files(files),
          serializer: Normal::Serializer::None,
          since: @since,
        )
      end

      def select_files(files)
        selector = file_selector_for(@language)
        files.any? ? selector.predefined(included: files, excluded: @excluded) : selector.excluding(@excluded)
      end

      def file_selector_for(language)
        case language
        when :ruby then FileSelector::Ruby
        when :java then FileSelector::Java
        when :javascript then FileSelector::JavaScript
        when :python then FileSelector::Python
        when :go then FileSelector::Go
        end
      end

      def complexity_for(language)
        case language
        when :ruby then Complexity::FlogCalculator
        when :java then Complexity::PMD::FolderCalculator
        when :javascript then Complexity::ESLintCalculator
        when :python then Complexity::PythonCalculator
        when :go then Complexity::GoCalculator
        end
      end
    end
  end
end
