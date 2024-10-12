# frozen_string_literal: true

module ChurnVsComplexity
  module Normal
    class Config
      def initialize(
        language:,
        serializer:,
        excluded: [],
        since: nil,
        relative_period: nil,
        complexity_validator: ComplexityValidator,
        since_validator: SinceValidator,
        **options
      )
        @language = language
        @serializer = serializer
        @excluded = excluded
        @since = since
        @relative_period = relative_period
        @complexity_validator = complexity_validator
        @since_validator = since_validator
        @options = options
      end

      def validate!
        LanguageValidator.validate!(@language)

        SerializerValidator.validate!(serializer: @serializer)

        @since_validator.validate!(since: @since, relative_period: @relative_period)
        RelativePeriodValidator.validate!(relative_period: @relative_period)
        @complexity_validator.validate!(@language)
      end

      def checker
        case @language
        when :java
          Engine.concurrent(
            complexity: Complexity::PMD::FolderCalculator,
            churn:,
            file_selector: FileSelector::Java.excluding(@excluded),
            serializer:,
            since: @since || @relative_period,
          )
        when :ruby
          Engine.concurrent(
            complexity: Complexity::FlogCalculator,
            churn:,
            file_selector: FileSelector::Ruby.excluding(@excluded),
            serializer:,
            since: @since || @relative_period,
          )
        when :javascript
          Engine.concurrent(
            complexity: Complexity::ESLintCalculator,
            churn:,
            file_selector: FileSelector::JavaScript.excluding(@excluded),
            serializer:,
            since: @since || @relative_period,
          )
        end
      end

      private

      def churn = Churn::GitCalculator

      def serializer
        case @serializer
        when :none
          Serializer::None
        when :csv
          Serializer::CSV
        when :graph
          Serializer::Graph.new
        when :summary
          Serializer::Summary
        when :pass_through
          Serializer::PassThrough
        end
      end
    end
  end
end
