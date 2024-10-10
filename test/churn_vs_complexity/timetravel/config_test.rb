# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Timetravel
    class ConfigTest < TLDR
      def test_that_it_creates_a_traveller_for_java
        result = config(language: :java).checker
        assert_instance_of Traveller, result
      end

      def test_that_it_creates_a_traveller_for_ruby
        result = config(language: :ruby).checker
        assert_instance_of Traveller, result
      end

      def test_that_it_supports_javascript
        config(language: :javascript).validate!
      end

      def test_that_it_creates_a_traveller_for_javascript
        result = config(language: :javascript).checker
        assert_instance_of Traveller, result
      end

      def test_that_it_raises_an_error_for_unsupported_language
        assert_raises(Error) { config(language: :csharp).validate! }
      end

      def test_that_it_raises_an_error_for_unsupported_serializer
        assert_raises(Error) { config(serializer: :jsonb).validate! }
      end

      def test_that_it_supports_graphing
        subject = config(serializer: :graph, since: '2024-01-01')
        subject.validate!
        result = subject.checker
        assert_instance_of Traveller, result
      end

      def test_that_it_validates_complexity_plugin
        complexity_validator = ValidatorMock.new
        subject = config(complexity_validator:)
        subject.validate!
        assert_equal :java, complexity_validator.validate_called_with
      end

      private

      def config(language: :java, serializer: :csv, excluded: [], complexity_validator: ValidatorStub,
                 since: nil, relative_period: :quarter, jump_days: 10)
        Config.new(language:, serializer:, excluded:, complexity_validator:, since:, relative_period:, jump_days:)
      end

      module ValidatorStub
        def self.validate!(language); end
      end

      class ValidatorMock
        attr_reader :validate_called_with

        def validate!(language)
          @validate_called_with = language
        end
      end
    end
  end
end
