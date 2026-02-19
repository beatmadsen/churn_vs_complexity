# frozen_string_literal: true

module ChurnVsComplexity
  module Triage
    class Config
      def initialize(
        language:,
        serializer: :json,
        targets: [],
        since: nil,
        excluded: [],
        complexity_validator: ComplexityValidator,
        since_validator: Normal::SinceValidator,
        **options
      )
        @language = language
        @serializer = serializer
        @targets = targets
        @since = since
        @excluded = excluded
        @complexity_validator = complexity_validator
        @since_validator = since_validator
        @options = options
      end

      def validate!
        LanguageValidator.validate!(@language)
        @since_validator.validate!(since: @since, relative_period: nil)
        @complexity_validator.validate!(@language)
      end

      def checker
        Checker.new(
          language: @language,
          serializer: triage_serializer,
          targets: @targets,
          since: @since,
          excluded: @excluded,
        )
      end

      private

      def triage_serializer
        case @serializer
        when :json
          Serializer::Json
        end
      end
    end
  end
end
