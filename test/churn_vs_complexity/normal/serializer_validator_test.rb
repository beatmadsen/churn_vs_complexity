# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Normal
    class SerializerValidatorTest < TLDR
      def test_should_accept_json_as_valid_serializer
        # Given: :json serializer
        # When/Then: no error raised
        SerializerValidator.validate!(serializer: :json)
      end
    end
  end
end
