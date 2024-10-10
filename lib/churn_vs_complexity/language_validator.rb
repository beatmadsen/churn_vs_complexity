# frozen_string_literal: true

module ChurnVsComplexity
  module LanguageValidator
    def self.validate!(language)
      raise ValidationError, "Unsupported language: #{language}" unless %i[java ruby javascript].include?(language)
    end
  end
end
