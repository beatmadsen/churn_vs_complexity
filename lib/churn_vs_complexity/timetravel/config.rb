# frozen_string_literal: true

module ChurnVsComplexity
  module Timetravel
    class Config
      def initialize(
        language:,
        serializer:,
        jump_days:, excluded: [],
        since: nil,
        relative_period: nil,
        complexity_validator: ComplexityValidator,
        since_validator: SinceValidator,
        factory: Factory,
        **options
      )
        @language = language
        @serializer = serializer
        @excluded = excluded
        @since = since
        @relative_period = relative_period
        @jump_days = jump_days
        @complexity_validator = complexity_validator
        @since_validator = since_validator
        @factory = factory
        @options = options
      end

      def validate!
        raise ValidationError, 'Must specify jump days!' if @jump_days.nil?

        LanguageValidator.validate!(@language)

        SerializerValidator.validate!(serializer: @serializer)

        @since_validator.validate!(since: @since)
        RelativePeriodValidator.validate!(relative_period: @relative_period)
        @complexity_validator.validate!(@language)
      end

      def checker = traveller(git_period: GitDate.git_period(@since, Time.now.to_date))

      private

      def traveller(git_period:)
        Traveller.new(
          git_period:,
          relative_period: @relative_period,
          engine: engine_config.checker,
          jump_days: @jump_days,
          serializer: serializer(git_period:),
          factory: @factory,
        )
      end

      def serializer(git_period:)
        Serializer.resolve(serializer: @serializer, git_period:, relative_period: @relative_period,
                           jump_days: @jump_days,)
      end

      def engine_config
        Normal::Config.new(
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
    end
  end
end
