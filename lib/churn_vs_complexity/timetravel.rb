# frozen_string_literal: true

require_relative 'timetravel/traveller'
require_relative 'timetravel/worktree'
require_relative 'timetravel/config'
require_relative 'timetravel/git_strategy'

module ChurnVsComplexity
  module Timetravel
    # TODO: unit test
    module SerializerValidator
      def self.validate!(serializer:)
        raise ValidationError, 'Does not support --summary in --timetravel mode' \
         if serializer == :summary
        raise ValidationError, "Unsupported serializer: #{serializer}" \
          unless %i[none csv graph].include?(serializer)
      end
    end

    # TODO: unit test
    module RelativePeriodValidator
      def self.validate!(relative_period:)
        raise ValidationError, 'Relative period is required in timetravel mode' if relative_period.nil?
        return if relative_period.nil? || %i[month quarter year].include?(relative_period)

        raise ValidationError, "Invalid relative period #{relative_period}"
      end
    end

    module SinceValidator
      def self.validate!(since:)
        # since can be nil, a date string or a keyword (:month, :quarter, :year)
        return if since.nil?

        raise ValidationError, "Invalid since value #{since}" unless since.is_a?(String)

        begin
          Date.strptime(since, '%Y-%m-%d')
        rescue Date::Error
          raise ValidationError, "Invalid date #{since}, please use correct format, YYYY-MM-DD"
        end
      end
    end

    class Factory
      def self.git_strategy(folder:) = GitStrategy.new(folder:)
      def self.pipe = IO.pipe
      def self.worker(engine:, worktree:) = Worker.new(engine:, worktree:)
      def self.worktree(root_folder:, git_strategy:, number:) = Worktree.new(root_folder:, git_strategy:, number:)
      def self.serializer(**args) = Serializer::Timetravel.resolve(**args)
    end

    class Worker
      def initialize(engine:, worktree:)
        @engine = engine
        @worktree = worktree
      end

      def schedule(chunk:, pipe:)
        fork do
          results = chunk.to_h do |commit|
            sha = commit.sha
            @worktree.checkout(sha)
            result = @engine.check(folder: @worktree.folder)
            [sha, result]
          end
          @worktree.remove
          pipe[1].puts(JSON.dump(results))
          pipe[1].close
        end
      end
    end
  end
end
