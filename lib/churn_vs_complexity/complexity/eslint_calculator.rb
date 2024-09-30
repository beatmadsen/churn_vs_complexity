# frozen_string_literal: true

module ChurnVsComplexity
  module Complexity
    module ESLintCalculator
      class << self
        def folder_based? = false

        def calculate(files:)
          dir_path = File.join(gem_root, 'tmp', 'eslint-support')
          script_path = File.join(dir_path, 'complexity-calculator.js')
          install_command = "npm install --prefix '#{dir_path}'"
          `#{install_command}`

          command = "node #{script_path} '#{files.to_json}'"
          complexity = `#{command}`

          raise Error, 'Failed to calculate complexity' if complexity.empty?

          all = JSON.parse(complexity)
          all.to_h do |abc|
            [abc['file'], abc['complexity']]
          end
        end

        private

        def gem_root
          File.expand_path('../../..', __dir__)
        end
      end
    end
  end
end
