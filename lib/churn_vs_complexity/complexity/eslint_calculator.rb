# frozen_string_literal: true

module ChurnVsComplexity
  module Complexity
    module ESLintCalculator
      class << self
        def folder_based? = false

        def calculate(file:)
          # TODO: Integrate with eslint
          { file => 42 }
        end
      end
    end
  end
end
