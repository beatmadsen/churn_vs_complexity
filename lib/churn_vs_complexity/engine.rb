# frozen_string_literal: true

module ChurnVsComplexity
  class Engine
    def initialize(file_selector:, calculator:, serializer:, since:)
      @file_selector = file_selector
      @calculator = calculator
      @serializer = serializer
      @since = since
    end

    def check(folder:)
      files = @file_selector.select_files(folder)
      result = @calculator.calculate(folder:, files:, since: @since)
      @serializer.serialize(result)
    end

    def self.concurrent(since:, complexity:, churn:, serializer: Serializer::None, file_selector: FileSelector::Any)
      Engine.new(since:, file_selector:, serializer:, calculator: ConcurrentCalculator.new(complexity:, churn:))
    end
  end
end
