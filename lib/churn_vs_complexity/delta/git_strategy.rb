# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    class GitStrategy
      def initialize(folder:)
        @repo = Git.open(folder)
        @folder = folder
      end
      
      def valid_commit?(commit:)
        @repo.object(commit)
        true
      rescue Git::GitExecuteError
        false
      end
    end
  end
end
