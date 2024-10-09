# frozen_string_literal: true

require 'digest'
require 'tmpdir'

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
      end

      def checkout(sha)
        raise Error, 'Worktree not prepared' if @folder.nil?

        @git_strategy.checkout_in_worktree(@folder, sha)
      end

      def remove
        raise Error, 'Worktree not prepared' if @folder.nil?

        @git_strategy.remove_worktree(@folder)
      end

      private

      def tt_folder
        folder_hash = Digest::SHA256.hexdigest(@root_folder)[0..7]
        File.join(Dir.tmpdir, 'churn_vs_complexity', 'timetravel', folder_hash)
      end

      def prepare_worktree
        worktree_folder = File.join(tt_folder, "worktree_#{@number}")

        unless File.directory?(worktree_folder)
          begin
            FileUtils.mkdir_p(worktree_folder)
          rescue StandardError
            nil
          end
          @git_strategy.add_worktree(worktree_folder)
        end

        worktree_folder
      end
    end
  end
end
