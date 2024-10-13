# frozen_string_literal: true

module ChurnVsComplexity
  module Complexity
    module PMD
      class FilesCalculator
        def initialize(root_folder:)
          @root_folder = root_folder
        end
      
        def folder_based? = false

        def calculate(files:)
          return Parser.empty_result if files.empty?

          cache_path = PMD.resolve_cache_path(@root_folder)
          files_arg = files.map { |file| "-d #{file}" }.join(' ')
          command = "pmd check #{files_arg} -R #{PMD.resolve_ruleset_path} -f json -t #{CONCURRENCY} --cache #{cache_path} 2>/dev/null"
          output = `#{command}`

          Parser.new.parse(output)
        
        end
      end
    end
  end
end
