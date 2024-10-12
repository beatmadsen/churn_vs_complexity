# frozen_string_literal: true

require_relative 'delta/config'
require_relative 'delta/checker'
require_relative 'delta/serializer'
require_relative 'delta/factory'

module ChurnVsComplexity
  module Delta
    module SerializerValidator
      def self.validate!(serializer:); end
    end

    class << self
      def engine(language:, excluded:, files:)
        Engine.concurrent(
          since: nil, complexity: complexity(language), churn: Churn::Disabled,
          serializer: Normal::Serializer::None, file_selector: FileSelector::Predefined.new(files, excluded),
        )
      end

      private

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
