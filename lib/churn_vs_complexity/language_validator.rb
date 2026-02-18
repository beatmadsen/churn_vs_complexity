# frozen_string_literal: true

module ChurnVsComplexity
  module LanguageValidator
    SUPPORTED = %i[java ruby javascript python go].freeze

    def self.validate!(language)
      raise ValidationError, "Unsupported language: #{language}" unless SUPPORTED.include?(language)
    end
  end
end
