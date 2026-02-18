# frozen_string_literal: true

require 'json'

module ChurnVsComplexity
  module Complexity
    module PythonCalculator
      class << self
        def folder_based? = false

        def calculate(files:)
          json_output = run_radon(files)
          parse_radon_output(json_output, files:)
        end

        def parse_radon_output(json_output, files:)
          data = JSON.parse(json_output)
          files.to_h do |file|
            blocks = data[file] || []
            total = blocks.sum { |b| b['complexity'] }
            [file, total]
          end
        end

        def check_dependencies!
          `radon --version`
        rescue Errno::ENOENT
          raise Error, 'Needs radon installed (pip install radon)'
        end

        private

        def run_radon(files)
          files_arg = files.map { |f| "'#{f}'" }.join(' ')
          `radon cc #{files_arg} -j`
        end
      end
    end
  end
end
