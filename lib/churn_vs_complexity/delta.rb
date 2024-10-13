# frozen_string_literal: true

require_relative 'delta/config'
require_relative 'delta/checker'
require_relative 'delta/serializer'
require_relative 'delta/factory'
require_relative 'delta/complexity_annotator'
require_relative 'delta/multi_checker'

module ChurnVsComplexity
  module Delta
    module SerializerValidator
      def self.validate!(serializer:); end
    end

    class << self
      def engine(language:, excluded:, files:)
        file_selector = file_selector(language:, included: files, excluded:)
        Engine.concurrent(
          since: nil, complexity: complexity(language), churn: Churn::Disabled,
          serializer: Normal::Serializer::None,
          file_selector:,
        )
      end

      private

      def file_selector(language:, included:, excluded:)
        case language
        when :java
          FileSelector::Java.predefined(included:, excluded:)
        when :ruby
          FileSelector::Ruby.predefined(included:, excluded:)
        when :javascript
          FileSelector::JavaScript.predefined(included:, excluded:)
        end
      end

      def complexity(language)
        case language
        when :java
          Complexity::PMD::FilesCalculator
        when :ruby
          Complexity::FlogCalculator
        when :javascript
          Complexity::ESLintCalculator
        end
      end
    end
  end
end
