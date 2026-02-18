# frozen_string_literal: true

require 'test_helper'

module ChurnVsComplexity
  module Delta
    class EngineWiringTest < TLDR
      def test_should_create_a_working_engine_for_python
        files = ['tmp/test-support/python/example.py']
        engine = Delta.engine(cache_components: [], language: :python, excluded: [], files:)
        result = engine.check(folder: 'tmp/test-support/python')
        assert_kind_of Hash, result
      end

      def test_should_create_a_working_engine_for_go
        files = ['tmp/test-support/go/main.go']
        engine = Delta.engine(cache_components: [], language: :go, excluded: [], files:)
        result = engine.check(folder: 'tmp/test-support/go')
        assert_kind_of Hash, result
      end
    end
  end
end
