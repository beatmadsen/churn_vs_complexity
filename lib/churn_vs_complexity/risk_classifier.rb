# frozen_string_literal: true

module ChurnVsComplexity
  # Classifies files into low/medium/high risk based on gamma score
  # (harmonic mean of churn and complexity).
  #
  # IMPORTANT: Complexity scores are NOT comparable across languages.
  # Each language uses a different tool with a different numeric scale.
  # All tools sum per-function scores across the file, but the magnitude differs:
  #
  #   Language       Tool      Metric                Trivial  Complex (~100 LOC)  Real-world range
  #   Ruby           Flog      Code pain (weighted)  0        ~286                0-88
  #   JavaScript/TS  ESLint    Cyclomatic complexity  3        ~62                 10-50
  #   Python         Radon     Cyclomatic complexity  1        ~44                 5-50
  #   Java           PMD       Cyclomatic complexity  1        ~39                 1-40
  #   Go             gocognit  Cognitive complexity   0        ~87                 0-50
  #
  # The DEFAULT_LOW and DEFAULT_HIGH thresholds below are rough midpoints
  # suitable for Java/Python/JS. They are too aggressive for Ruby (Flog
  # scores 3-7x higher) and Go (cognitive complexity penalises nesting).
  # Use the constructor to pass language-appropriate thresholds.
  class RiskClassifier
    DEFAULT_LOW = 10
    DEFAULT_HIGH = 25

    LANGUAGE_DEFAULTS = {
      ruby: { low: 30, high: 70 },
      go: { low: 15, high: 40 },
    }.freeze

    RECOMMENDATIONS = {
      'low' => 'Safe for quick changes.',
      'medium' => 'Exercise judgement; consider tests for non-trivial changes.',
      'high' => 'Write tests before modifying. Consider multi-agent review.',
    }.freeze

    def initialize(low: DEFAULT_LOW, high: DEFAULT_HIGH, language: nil)
      defaults = LANGUAGE_DEFAULTS.fetch(language, {})
      @low = defaults.fetch(:low, low)
      @high = defaults.fetch(:high, high)
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
