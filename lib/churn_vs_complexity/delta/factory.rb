# frozen_string_literal: true

module ChurnVsComplexity
  module Delta
    module Factory
      def self.complexity_validator = ComplexityValidator
      def self.git_strategy(folder:) = GitStrategy.new(folder:)
    end
  end
end
