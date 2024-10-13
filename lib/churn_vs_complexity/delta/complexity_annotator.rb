# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class ComplexityAnnotator
      def initialize(factory:, changes:)
        @factory = factory
        @changes = changes
      end

      def enhance(worktree_folder:, language:, excluded:)
        @changes.each do |change|
          change[:full_path] = File.join(worktree_folder, change[:path])
        end

        files = @changes.reject { |change| change[:type] == :deleted }.map { |change| change[:full_path] }

        engine = @factory.engine(language:, excluded:, files:)

        values_by_file = engine.check(folder: worktree_folder)[:values_by_file]

        valid_extensions = FileSelector.extensions(language)
        @changes.select! { |change| valid_extensions.any? { |ext| change[:path].end_with?(ext) } }
        @changes.each do |annotated_file|
          annotated_file[:complexity] = values_by_file.dig(annotated_file[:full_path], 1)
        end
      end
    end
  end
end
