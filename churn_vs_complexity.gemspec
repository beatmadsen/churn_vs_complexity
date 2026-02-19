# frozen_string_literal: true

require_relative 'lib/churn_vs_complexity/version'

Gem::Specification.new do |spec|
  spec.name          = 'churn_vs_complexity'
  spec.version       = ChurnVsComplexity::VERSION
  spec.authors       = ['Erik T. Madsen']
  spec.email         = ['beatmadsen@gmail.com']
  spec.summary       = 'Analyse churn vs complexity to find refactoring hotspots, gate CI quality, triage risky files, and track codebase health over time.'
  spec.description   = "Correlates file churn (how often files change) with complexity scores to identify refactoring hotspots. Supports Ruby, JavaScript/TypeScript, Java, Python, and Go. Modes include hotspots ranking, triage assessment, CI quality gate, diff comparison, focus sessions, and timetravel history. Inspired by Michael Feathers' article \"Getting Empirical about Refactoring\"."
  spec.homepage      = 'https://github.com/beatmadsen/churn_vs_complexity'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.3'

  spec.metadata['source_code_uri'] = 'https://github.com/beatmadsen/churn_vs_complexity'
  spec.metadata['changelog_uri'] = 'https://github.com/beatmadsen/churn_vs_complexity/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir = 'bin'
  spec.executables = ['churn_vs_complexity']
  spec.require_paths = ['lib']

  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'flog', '~> 4.8'
  spec.add_dependency 'git', '~> 2.1'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
