# frozen_string_literal: true

module ChurnVsComplexity
  module Complexity
    module PMD
      module FolderCalculator
        class << self
          def folder_based? = true

          def calculate(folder:)
            cache_path = PMD.resolve_cache_path(folder)
            output = `pmd check -d #{folder} -R #{PMD.resolve_ruleset_path} -f json -t #{CONCURRENCY} --cache #{cache_path} 2>/dev/null`
            
            Parser.new.parse(output)
          end
        end
      end
    end
  end
end
