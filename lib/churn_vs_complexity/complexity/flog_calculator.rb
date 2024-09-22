# frozen_string_literal: true

require 'flog'

module ChurnVsComplexity
  module Complexity
    module FlogCalculator
      class << self
        def folder_based? = false

        def calculate(file:)
          flog = Flog.new
          flog.flog(file)
          { file => flog.total_score }
        end
      end
    end
  end
end
