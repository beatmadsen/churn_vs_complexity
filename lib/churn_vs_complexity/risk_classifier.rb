# frozen_string_literal: true

module ChurnVsComplexity
  class RiskClassifier
    DEFAULT_LOW = 10
    DEFAULT_HIGH = 25

    RECOMMENDATIONS = {
      'low' => 'Safe for quick changes.',
      'medium' => 'Exercise judgement; consider tests for non-trivial changes.',
      'high' => 'Write tests before modifying. Consider multi-agent review.',
    }.freeze

    def initialize(low: DEFAULT_LOW, high: DEFAULT_HIGH)
      @low = low
      @high = high
    end

    def classify(gamma_score:)
      risk = if gamma_score < @low
               'low'
             elsif gamma_score > @high
               'high'
             else
               'medium'
             end

      { risk:, recommendation: RECOMMENDATIONS[risk] }
    end

    def self.classify(gamma_score:)
      new.classify(gamma_score:)
    end
  end
end
