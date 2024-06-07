# frozen_string_literal: true

module ChurnVsComplexity
  class Config
    def initialize(
      language:,
      serializer:,
      excluded: [],
      graph_title: nil,
      complexity_validator: ComplexityValidator
    )
      @language = language
      @serializer = serializer
      @excluded = excluded
      @complexity_validator = complexity_validator
      @graph_title = graph_title
    end

    def validate!
      raise Error, "Unsupported language: #{@language}" unless %i[java ruby].include?(@language)
      raise Error, "Unsupported serializer: #{@serializer}" unless %i[none csv graph].include?(@serializer)
      raise Error, 'Please provide a title for the graph' if @serializer == :graph && @graph_title.nil?

      @complexity_validator.validate!(@language)
    end

    def to_engine
      case @language
      when :java
        Engine.concurrent(
          complexity: Complexity::PMDCalculator,
          churn:,
          file_selector: FileSelector::Java.excluding(@excluded),
          serializer:,
        )
      when :ruby
        Engine.concurrent(
          complexity: Complexity::FlogCalculator,
          churn:,
          file_selector: FileSelector::Ruby.excluding(@excluded),
          serializer:,
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
        Serializer::Graph.new(title: @graph_title)
      end
    end

    module ComplexityValidator
      def self.validate!(language)
        case language
        when :java
          Complexity::PMDCalculator.check_dependencies!
        end
      end
    end
  end
end
