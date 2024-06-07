# frozen_string_literal: true

module ChurnVsComplexity
  class Engine
    def initialize(file_selector:, calculator:, serializer:)
      @file_selector = file_selector
      @calculator = calculator
      @serializer = serializer
    end

    def check(folder:, since:)
      files = @file_selector.select_files(folder)
      result = @calculator.calculate(folder:, files:, since:)
      @serializer.serialize(result)
    end

    def self.concurrent(complexity:, churn:, serializer: Serializer::None, file_selector: FileSelector::Any)
      Engine.new(file_selector:, serializer:, calculator: ConcurrentCalculator.new(complexity:, churn:))
    end
  end
end
