# frozen_string_literal: true

require 'test_helper'

class IntegrationTest < TLDR
  def test_that_it_has_a_version_number
    refute_nil ::ChurnVsComplexity::VERSION
  end
end
