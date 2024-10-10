# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Normal
    class ConfigTest < TLDR
      def test_that_it_creates_an_engine_for_java
        result = config(language: :java).checker
        assert_instance_of Engine, result
      end

      def test_that_it_creates_an_engine_for_ruby
        result = config(language: :ruby).checker
        assert_instance_of Engine, result
      end

      def test_that_it_supports_javascript
        config(language: :javascript).validate!
      end

      def test_that_it_creates_an_engine_for_javascript
        result = config(language: :javascript).checker
        assert_instance_of Engine, result
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
        assert_instance_of Engine, result
      end

      def test_that_it_supports_summary
        subject = config(serializer: :summary)
        subject.validate!
        result = subject.checker
        assert_instance_of Engine, result
      end

      def test_that_it_validates_relative_period
        assert_raises(ValidationError) { config(relative_period: :invalid).validate! }
      end

      def test_that_it_validates_since
        assert_raises(ValidationError) { config(since: 'invalid').validate! }
      end

      def test_that_it_cannot_have_both_since_and_relative_period
        assert_raises(ValidationError) { config(since: '2024-01-01', relative_period: :quarter).validate! }
      end

      def test_that_it_validates_complexity_plugin
        complexity_validator = ValidatorMock.new
        subject = config(complexity_validator:)
        subject.validate!
        assert_equal :java, complexity_validator.validate_called_with
      end

      private

      def config(language: :java, serializer: :csv, excluded: [], complexity_validator: ValidatorStub,
                  since: nil, relative_period: nil)
        Config.new(language:, serializer:, excluded:, complexity_validator:, since:, relative_period:)
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
