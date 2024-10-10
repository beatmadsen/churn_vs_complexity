# frozen_string_literal: true

require 'test_helper'

class JavaIntegrationTest < TLDR
  def test_java_graph_completes
    config = ChurnVsComplexity::Normal::Config.new(
      language: :java,
      serializer: :graph,
      excluded: %w[exclude-me me-too-also],
      since: '2000-01-01',
    )
    config.validate!
    result = config.checker.check(folder: 'tmp/test-support/java')
    refute_nil result
    refute_empty result
  end
end
