# frozen_string_literal: true

require 'json'
require 'etc'

require_relative 'churn_vs_complexity/version'
require_relative 'churn_vs_complexity/engine'
require_relative 'churn_vs_complexity/concurrent_calculator'
require_relative 'churn_vs_complexity/file_selector'
require_relative 'churn_vs_complexity/complexity'
require_relative 'churn_vs_complexity/churn'
require_relative 'churn_vs_complexity/cli'
require_relative 'churn_vs_complexity/serializer'
require_relative 'churn_vs_complexity/git_date'
require_relative 'churn_vs_complexity/timetravel'
require_relative 'churn_vs_complexity/complexity_validator'
require_relative 'churn_vs_complexity/normal'

module ChurnVsComplexity
  class Error < StandardError; end
  class ValidationError < Error; end
end
