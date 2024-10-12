# frozen_string_literal: true

require_relative 'delta/config'
require_relative 'delta/checker'
require_relative 'delta/serializer'
require_relative 'delta/factory'

module ChurnVsComplexity
  module Delta
    module SerializerValidator
      def self.validate!(serializer:); end
    end
  end
end
