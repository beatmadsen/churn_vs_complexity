# frozen_string_literal: true

module ChurnVsComplexity
  module Complexity
    module PMDCalculator
      CONCURRENCY = Etc.nprocessors

      class << self
        def folder_based? = true

        def calculate(folder:)
          cache_path = resolve_cache_path
          output = `pmd check -d #{folder} -R #{resolve_ruleset_path} -f json -t #{CONCURRENCY}  --cache #{cache_path}`
          File.delete(cache_path)

          Parser.new.parse(output)
        end

        def check_dependencies!
          `pmd --help`
        rescue StandardError
          raise Error, 'Could not execute PMD using command pmd'
        end

        private

        def resolve_ruleset_path
          ruleset_path = File.join(gem_root, 'tmp', 'pmd-support', 'ruleset.xml')
          raise "ruleset.xml not found in #{ruleset_path}" unless File.exist?(ruleset_path)

          ruleset_path
        end

        def resolve_cache_path
          File.join(gem_root, 'tmp', 'pmd-support', "pmd-cache-#{Process.pid}")
        end

        def gem_root
          File.expand_path('../../..', __dir__)
        end
      end

      class Parser
        def parse(output)
          doc = JSON.parse(output)
          doc['files'].each_with_object({}) do |file, result|
            result[file['filename']] =
              file['violations'].sum { |violation| extract_complexity(violation) }
          end
        end

        private

        def extract_complexity(violation)
          # Find text 'total cyclomatic complexity of <number>'
          violation['description'].match(/total cyclomatic complexity of (\d+)/)[1].to_i
        end
      end
    end
  end
end
