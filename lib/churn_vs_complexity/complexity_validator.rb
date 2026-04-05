# frozen_string_literal: true

module ChurnVsComplexity
  module ComplexityValidator
    def self.validate!(language)
      case language
      when :java
        Complexity::PMD.check_dependencies!
      when :javascript
        Complexity::ESLintCalculator.check_dependencies!
      when :python
        Complexity::PythonCalculator.check_dependencies!
      when :go
        Complexity::GoCalculator.check_dependencies!
      when :kotlin
        Complexity::KotlinCalculator.check_dependencies!
      when :rust
        Complexity::RustCalculator.check_dependencies!
      end
    end
  end
end
