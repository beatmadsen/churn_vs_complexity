# frozen_string_literal: true

require_relative 'normal/config'
require_relative 'normal/serializer'

module ChurnVsComplexity
  module Normal
    # TODO: unit test
    module SerializerValidator
      def self.validate!(serializer:)
        raise ValidationError, "Unsupported serializer: #{serializer}" \
          unless %i[none csv graph summary].include?(serializer)
      end
    end

    # TODO: unit test
    module RelativePeriodValidator
      def self.validate!(relative_period:)
        return if relative_period.nil? || %i[month quarter year].include?(relative_period)

        raise ValidationError, "Invalid relative period #{relative_period}"
      end
    end

    module SinceValidator
      def self.validate!(since:, relative_period:)
        # since can be nil, a date string or a keyword (:month, :quarter, :year)
        return if since.nil?

        unless since.nil? || relative_period.nil?
          raise ValidationError,
                '--since and relative period (--month, --quarter, --year) cannot be used together in normal mode'
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
