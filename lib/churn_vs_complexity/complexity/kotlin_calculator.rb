# frozen_string_literal: true

require 'csv'
require 'open3'

module ChurnVsComplexity
  module Complexity
    module KotlinCalculator
      class << self
        attr_writer :command_runner

        def folder_based? = false

        def calculate(files:)
          csv_output = run_lizard(files)
          parse_lizard_output(csv_output, files:)
        end

        def parse_lizard_output(csv_output, files:)
          scores = Hash.new(0)
          CSV.parse(csv_output).each do |row|
            next if row.length < 7

            scores[row[6]] += row[1].to_i
          end
          files.to_h { |file| [file, scores[file] || 0] }
        end

        def check_dependencies!
          command_runner.call('lizard --version 2>&1')
        rescue Errno::ENOENT
          raise Error, 'Needs lizard installed (pip install lizard)'
        end

        private

        def command_runner
          @command_runner || Open3.method(:capture2)
        end

        def run_lizard(files)
          files_arg = files.map { |f| "'#{f}'" }.join(' ')
          stdout, status = command_runner.call("lizard --csv #{files_arg}")
          raise Error, "lizard failed (exit #{status.exitstatus}). Is it installed?" unless status.success?

          stdout
        end
      end
    end
  end
end
