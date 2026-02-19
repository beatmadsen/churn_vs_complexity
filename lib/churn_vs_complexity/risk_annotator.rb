# frozen_string_literal: true

module ChurnVsComplexity
  module RiskAnnotator
    def self.annotate(values_by_file, language: nil, classifier: RiskClassifier.new(language: language))
      values_by_file.map { |file, values| build_entry(file, values, classifier) }
    end

    def self.risk_summary(entries)
      counts = entries.each_with_object(Hash.new(0)) { |e, acc| acc["#{e[:risk]}_risk"] += 1 }
      { high_risk: counts['high_risk'], medium_risk: counts['medium_risk'], low_risk: counts['low_risk'] }
    end

    def self.build_entry(file, values, classifier)
      gamma = GammaScore.calculate(values[0], values[1])
      classification = classifier.classify(gamma_score: gamma)

      {
        file:, churn: values[0], complexity: values[1].to_f, gamma_score: gamma.round(2),
        risk: classification[:risk], recommendation: classification[:recommendation],
      }
    end

    private_class_method :build_entry
  end
end
