# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'churn_vs_complexity'
require 'tldr'

PROJECT_ROOT_FOLDER = File.expand_path('..', __dir__)

module ChurnVsComplexity
  module Normal
    module Serializer
      GitPeriod = Data.define(:requested_start_date, :end_date)
    end
  end
end
