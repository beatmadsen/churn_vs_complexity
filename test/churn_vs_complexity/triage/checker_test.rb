# frozen_string_literal: true

require 'test_helper'
require 'json'

module ChurnVsComplexity
  module Triage
    class CheckerTest < TLDR
      def test_should_analyze_individual_files_when_given_file_paths
        # Given: targets include individual .rb files that exist in this project
        targets = [
          'lib/churn_vs_complexity/version.rb',
          'lib/churn_vs_complexity/gamma_score.rb',
        ]
        checker = Checker.new(
          language: :ruby,
          serializer: Serializer::Json,
          targets: targets,
          since: '2000-01-01',
          excluded: [],
        )

        # When: we run the check
        result = checker.check
        parsed = JSON.parse(result)

        # Then: only the specified files should be analyzed
        files = parsed['files']
        file_paths = files.map { |f| f['file'] }
        assert_includes file_paths, 'lib/churn_vs_complexity/version.rb'
        assert_includes file_paths, 'lib/churn_vs_complexity/gamma_score.rb'
        assert_equal 2, files.size, 'Should only analyze the specified files'
      end

      def test_should_analyze_directory_when_given_directory_target
        # Given: a directory target
        checker = Checker.new(
          language: :ruby,
          serializer: Serializer::Json,
          targets: ['lib/churn_vs_complexity/normal/serializer'],
          since: '2000-01-01',
          excluded: [],
        )

        # When: we run the check
        result = checker.check
        parsed = JSON.parse(result)

        # Then: all Ruby files in that directory should be analyzed
        files = parsed['files']
        refute_empty files, 'Should find Ruby files in the directory'
        files.each do |f|
          assert f['file'].end_with?('.rb'), 'Should only include Ruby files'
        end
      end
    end
  end
end
