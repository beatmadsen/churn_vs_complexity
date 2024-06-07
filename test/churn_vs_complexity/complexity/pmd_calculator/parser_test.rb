# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Complexity
    module PMDCalculator
      class ParserTest < TLDR
        def test_that_it_does_x
          parser = Parser.new
          result = parser.parse(SAMPLE_OUTPUT)
          assert_instance_of Hash, result
          expected_result = {
            'tmp/test-support/java/small-example/src/main/java/org/example/Main.java' => 1,
            'tmp/test-support/java/small-example/src/main/java/org/example/spice/Checker.java' => 6,
          }
          assert_equal expected_result, result
        end
      end

      SAMPLE_OUTPUT = <<~JSON
        {
            "formatVersion": 0,
            "pmdVersion": "7.0.0",
            "timestamp": "2024-04-13T20:01:48.503Z",
            "files": [
              {
                "filename": "tmp/test-support/java/small-example/src/main/java/org/example/Main.java",
                "violations": [
                  {
                    "beginline": 5,
                    "begincolumn": 8,
                    "endline": 5,
                    "endcolumn": 13,
                    "description": "The class \u0027Main\u0027 has a total cyclomatic complexity of 1 (highest 1).",
                    "rule": "CyclomaticComplexity",
                    "ruleset": "Design",
                    "priority": 3,
                    "externalInfoUrl": "https://docs.pmd-code.org/pmd-doc-7.0.0/pmd_rules_java_design.html#cyclomaticcomplexity"
                  }
                ]
              },
              {
                "filename": "tmp/test-support/java/small-example/src/main/java/org/example/spice/Checker.java",
                "violations": [
                  {
                    "beginline": 7,
                    "begincolumn": 8,
                    "endline": 7,
                    "endcolumn": 13,
                    "description": "The class \u0027Checker\u0027 has a total cyclomatic complexity of 6 (highest 5).",
                    "rule": "CyclomaticComplexity",
                    "ruleset": "Design",
                    "priority": 3,
                    "externalInfoUrl": "https://docs.pmd-code.org/pmd-doc-7.0.0/pmd_rules_java_design.html#cyclomaticcomplexity"
                  }
                ]
              }
            ],
            "suppressedViolations": [],
            "processingErrors": [],
            "configurationErrors": []
          }
      JSON
    end
  end
end
