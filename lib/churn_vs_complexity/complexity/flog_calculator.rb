# frozen_string_literal: true

require 'flog'

module ChurnVsComplexity
  module Complexity
    module FlogCalculator
      class << self
        def folder_based? = false

        def calculate(files:)
          flog = Flog.new
          #  TODO: Run this concurrently
          files.to_h do |file|
            flog.flog(file)
            [file, flog.total_score]
          end
        end
      end
    end
  end
end
