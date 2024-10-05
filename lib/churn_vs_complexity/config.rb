# frozen_string_literal: true

module ChurnVsComplexity
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
      raise ValidationError, "Unsupported language: #{@language}" unless %i[java ruby javascript].include?(@language)

      SerializerValidator.validate!(serializer: @serializer, mode: @options[:mode])

      @since_validator.validate!(since: @since, relative_period: @relative_period, mode: @options[:mode])
      RelativePeriodValidator.validate!(relative_period: @relative_period, mode: @options[:mode])
      @complexity_validator.validate!(@language)
    end

    def timetravel
      engine = timetravel_engine_config.to_engine
      Timetravel.new(
        since: @since,
        relative_period: @relative_period,
        engine:,
        jump_days: @options[:jump_days],
        serializer: @serializer,
      )
    end

    def to_engine
      case @language
      when :java
        Engine.concurrent(
          complexity: Complexity::PMDCalculator,
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

    def timetravel_engine_config
      Config.new(
        language: @language,
        serializer: :pass_through,
        excluded: @excluded,
        since: nil, # since has a different meaning in timetravel mode
        relative_period: @relative_period,
        complexity_validator: @complexity_validator,
        since_validator: @since_validator,
        **@options,
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
      when :pass_through
        Serializer::PassThrough
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

    # TODO: unit test
    module SerializerValidator
      def self.validate!(serializer:, mode:)
        raise ValidationError, "Unsupported serializer: #{serializer}" \
          unless %i[none csv graph summary].include?(serializer)
        raise ValidationError, 'Does not support --summary in --timetravel mode' \
         if serializer == :summary && mode == :timetravel
      end
    end

    # TODO: unit test
    module RelativePeriodValidator
      def self.validate!(relative_period:, mode:)
        if mode == :timetravel && relative_period.nil?
          raise ValidationError,
                'Relative period is required in timetravel mode'
        end
        return if relative_period.nil? || %i[month quarter year].include?(relative_period)

        raise ValidationError, "Invalid relative period #{relative_period}"
      end
    end

    module SinceValidator
      def self.validate!(since:, relative_period:, mode:)
        # since can be nil, a date string or a keyword (:month, :quarter, :year)
        return if since.nil?

        unless mode == :timetravel || since.nil? || relative_period.nil?
          raise ValidationError,
                '--since and relative period (--month, --quarter, --year) can only be used together in --timetravel mode'
        end

        raise ValidationError, "Invalid since value #{since}" unless since.is_a?(String)

        begin
          Date.strptime(since, '%Y-%m-%d')
        rescue Date::Error
          raise ValidationError, "Invalid date #{since}, please use correct format, YYYY-MM-DD"
        end
      end
    end
  end
end
