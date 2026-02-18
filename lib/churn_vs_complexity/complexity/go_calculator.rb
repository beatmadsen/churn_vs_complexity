# frozen_string_literal: true

require 'json'
require 'open3'

module ChurnVsComplexity
  module Complexity
    module GoCalculator
      class << self
        def folder_based? = false

        def calculate(files:)
          json_output = run_gocognit(files)
          parse_gocognit_output(json_output, files:)
        end

        def parse_gocognit_output(json_output, files:)
          stats = JSON.parse(json_output)
          scores = stats.group_by { |s| s.dig('Pos', 'Filename') }
                        .transform_values { |funcs| funcs.sum { |f| f['Complexity'] } }
          files.to_h { |file| [file, scores[file] || 0] }
        end

        def check_dependencies!
          Open3.capture2('gocognit', '--help')
        rescue Errno::ENOENT
          raise Error, 'Needs gocognit installed (go install github.com/uudashr/gocognit/cmd/gocognit@latest)'
        end

        private

        def run_gocognit(files)
          files_arg = files.map { |f| "'#{f}'" }.join(' ')
          `gocognit -json #{files_arg}`
        end
      end
    end
  end
end
