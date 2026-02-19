# frozen_string_literal: true

module ChurnVsComplexity
  module Diff
    class Checker
      def initialize(engine_builder:, serializer:, reference:)
        @engine_builder = engine_builder
        @serializer = serializer
        @reference = reference
      end

      def check(folder:)
        worktree = setup_worktree(folder:)

        begin
          before_result = @engine_builder.call.check(folder: worktree.folder)
          after_result = @engine_builder.call.check(folder:)
          serialize_results(before_result, after_result)
        ensure
          cleanup_worktree(worktree)
        end
      end

      private

      def setup_worktree(folder:)
        git_strategy = GitStrategy.new(folder:)
        worktree_number = "diff_#{Thread.current.object_id}"
        worktree = Timetravel::Worktree.new(root_folder: folder, git_strategy:, number: worktree_number)
        worktree.prepare
        worktree.checkout(@reference)
        worktree
      end

      def cleanup_worktree(worktree)
        worktree.remove
      rescue StandardError
        FileUtils.rm_rf(worktree.folder) if worktree&.folder
      end

      def serialize_results(before_result, after_result)
        @serializer.serialize(reference: @reference, before: before_result, after: after_result)
      end
    end
  end
end
