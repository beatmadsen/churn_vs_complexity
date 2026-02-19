# frozen_string_literal: true

module ChurnVsComplexity
  module Diff
    class Config
      def initialize(
        language:,
        reference:,
        serializer: :json,
        since: nil,
        excluded: [],
        complexity_validator: ComplexityValidator,
        since_validator: Normal::SinceValidator,
        **options
      )
        @language = language
        @reference = reference
        @serializer = serializer
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
          engine_builder: method(:build_engine),
          serializer: diff_serializer,
          reference: @reference,
        )
      end

      private

      def build_engine
        Normal::Config.new(language: @language, serializer: :none, since: @since, excluded: @excluded).checker
      end

      def diff_serializer
        case @serializer
        when :json then Serializer::Json
        end
      end
    end
  end
end
