# frozen_string_literal: true

module ChurnVsComplexity
  module Hotspots
    class Config
      def initialize(
        language:,
        serializer: :json,
        since: nil,
        excluded: [],
        complexity_validator: ComplexityValidator,
        since_validator: Normal::SinceValidator,
        **options
      )
        @language = language
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
        normal_config = Normal::Config.new(
          language: @language,
          serializer: :none,
          since: @since,
          excluded: @excluded,
        )
        Checker.new(engine: normal_config.checker, serializer: hotspots_serializer, language: @language)
      end

      private

      def hotspots_serializer
        case @serializer
        when :json then Serializer::Json
        when :markdown then Serializer::Markdown
        end
      end
    end
  end
end
