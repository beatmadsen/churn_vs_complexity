# frozen_string_literal: true

module ChurnVsComplexity
  module ComplexityValidator
    def self.validate!(language)
      case language
      when :java
        Complexity::PMDCalculator.check_dependencies!
      when :javascript
        Complexity::ESLintCalculator.check_dependencies!
      end
    end
  end
end
