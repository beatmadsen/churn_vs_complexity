# frozen_string_literal: true

module ChurnVsComplexity
  class Config
    def initialize(
      language:,
      serializer:,
      excluded: [],
      since: nil,
      complexity_validator: ComplexityValidator,
      since_validator: SinceValidator,
      **options
    )
      @language = language
      @serializer = serializer
      @excluded = excluded
      @since = since
      @complexity_validator = complexity_validator
      @since_validator = since_validator
      @options = options
    end

    def validate!
      raise Error, "Unsupported language: #{@language}" unless %i[java ruby javascript].include?(@language)
      raise Error, "Unsupported serializer: #{@serializer}" unless %i[none csv graph summary].include?(@serializer)

      @since_validator.validate!(@since)
      @complexity_validator.validate!(@language)
    end

    def timetravel
      engine = with_summary_hash.to_engine
      Timetravel.new(since: @since, engine:, jump_days: @options[:jump_days])
    end

    def to_engine
      case @language
      when :java
        Engine.concurrent(
          complexity: Complexity::PMDCalculator,
          churn:,
          file_selector: FileSelector::Java.excluding(@excluded),
          serializer:,
          since: @since,
        )
      when :ruby
        Engine.concurrent(
          complexity: Complexity::FlogCalculator,
          churn:,
          file_selector: FileSelector::Ruby.excluding(@excluded),
          serializer:,
          since: @since,
        )
      when :javascript
        Engine.concurrent(
          complexity: Complexity::ESLintCalculator,
          churn:,
          file_selector: FileSelector::JavaScript.excluding(@excluded),
          serializer:,
          since: @since,
        )
      end
    end

    private

    def with_summary_hash
      Config.new(
        language: @language,
        serializer: :summary_hash,
        excluded: @excluded,
        since: @since,
        complexity_validator: @complexity_validator,
        since_validator: @since_validator,
        **@options
      )
    end

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
      when :summary_hash
        Serializer::SummaryHash
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

    module SinceValidator
      def self.validate!(since)
        # since can be nil, a date string or a keyword (:month, :quarter, :year)
        return if since.nil?

        if since.is_a?(Symbol)
          raise Error, "Invalid since value #{since}" unless %i[month quarter year].include?(since)
        elsif since.is_a?(String)
          begin
            Date.strptime(since, '%Y-%m-%d')
          rescue StandardError
            raise Error, "Invalid date #{since}, please use correct format, YYYY-MM-DD"
          end
        else
          raise Error, "Invalid since value #{since}"
        end
      end
    end
  end
end
