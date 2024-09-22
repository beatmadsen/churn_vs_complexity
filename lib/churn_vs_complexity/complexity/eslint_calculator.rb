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

        private

        def resolve_script_path
          File.join(gem_root, 'tmp', 'eslint-support', 'complexity-calculator.js')
        end

        def gem_root
          File.expand_path('../../..', __dir__)
        end
      end
    end
  end
end
