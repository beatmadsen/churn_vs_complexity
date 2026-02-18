# frozen_string_literal: true

require 'json'
require 'open3'

module ChurnVsComplexity
  module Complexity
    module PythonCalculator
      class << self
        attr_writer :command_runner

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
          command_runner.call('radon --version 2>&1')
        rescue Errno::ENOENT
          raise Error, 'Needs radon installed (pip install radon)'
        end

        private

        def command_runner
          @command_runner || Open3.method(:capture2)
        end

        def run_radon(files)
          files_arg = files.map { |f| "'#{f}'" }.join(' ')
          stdout, status = command_runner.call("radon cc #{files_arg} -j")
          raise Error, "radon failed (exit #{status.exitstatus}). Is it installed?" unless status.success?

          stdout
        end
      end
    end
  end
end
