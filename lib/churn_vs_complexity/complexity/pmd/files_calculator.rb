# frozen_string_literal: true

module ChurnVsComplexity
  module Complexity
    module PMD
      module FilesCalculator
        class << self
          def folder_based? = false

          def calculate(files:)
            return Parser.empty_result if files.empty?

            cache_path = PMD.resolve_cache_path
            files_arg = files.map { |file| "-d #{file}" }.join(' ')
            command = "pmd check #{files_arg} -R #{PMD.resolve_ruleset_path} -f json -t #{CONCURRENCY} --cache #{cache_path} 2>/dev/null"
            output = `#{command}`
            File.delete(cache_path)

            Parser.new.parse(output)
          end
        end
      end
    end
  end
end
