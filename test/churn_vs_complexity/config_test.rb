# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  class ConfigTest < TLDR
    def test_that_it_creates_an_engine_for_java
      result = config(language: :java).to_engine
      assert_instance_of Engine, result
    end

    def test_that_it_creates_an_engine_for_ruby
      result = config(language: :ruby).to_engine
      assert_instance_of Engine, result
    end

    def test_that_it_raises_an_error_for_unsupported_language
      assert_raises(Error) { config(language: :csharp).validate! }
    end

    def test_that_it_raises_an_error_for_unsupported_serializer
      assert_raises(Error) { config(serializer: :jsonb).validate! }
    end

    def test_that_it_supports_graphing
      subject = config(serializer: :graph, graph_title: 'This is the title')
      subject.validate!
      result = subject.to_engine
      assert_instance_of Engine, result
    end

    def test_that_graphing_needs_title
      assert_raises(Error) { config(serializer: :graph).validate! }
    end

    def test_that_it_validates_complexity_plugin
      complexity_validator = ValidatorMock.new
      subject = config(complexity_validator:)
      subject.validate!
      assert_equal :java, complexity_validator.validate_called_with
    end

    private

    def config(language: :java, serializer: :csv, excluded: [], complexity_validator: ValidatorStub,
               graph_title: nil)
      Config.new(language:, serializer:, excluded:, complexity_validator:, graph_title:)
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
