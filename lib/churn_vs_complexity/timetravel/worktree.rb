# frozen_string_literal: true

module ChurnVsComplexity
  module Timetravel
    class Worktree
      attr_reader :folder

      def initialize(root_folder:, git_strategy:, number:)
        @root_folder = root_folder
        @git_strategy = git_strategy
        @number = number
      end

      def prepare
        @folder = prepare_worktree
      rescue StandardError => e
        raise Error, "Failed to prepare worktree: #{e.message}"
      end

      def checkout(sha)
        raise Error, 'Worktree not prepared' if @folder.nil?

        @git_strategy.checkout_in_worktree(@folder, sha)
      end

      def remove
        raise Error, 'Worktree not prepared' if @folder.nil?

        @git_strategy.remove_worktree(@folder)
      end

      protected

      def tt_folder
        File.join(ChurnVsComplexity.tmp_dir_path(@root_folder), 'timetravel')
      end

      private

      def worktree_folder
        @worktree_folder ||= File.join(tt_folder, "worktree_#{@number}")
      end

      def prepare_worktree
        if File.directory?(worktree_folder)
          prepare_worktree_in_existing_dir
        else
          create_worktree_folder
          @git_strategy.add_worktree(worktree_folder)
        end

        worktree_folder
      end

      def create_worktree_folder
        FileUtils.mkdir_p(worktree_folder)
      rescue Errno::EEXIST
        # Folder was created by another process, which is fine
      end

      def prepare_worktree_in_existing_dir
        Git.open(worktree_folder)
      rescue ArgumentError
        # Delete the worktree folder and try again
        FileUtils.rm_rf(worktree_folder)
        prepare_worktree
      end

      class Error < ChurnVsComplexity::Error; end
    end
  end
end
