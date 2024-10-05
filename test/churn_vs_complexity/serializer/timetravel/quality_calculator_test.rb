
require 'test_helper'

module ChurnVsComplexity
  module Serializer
    module Timetravel
      class QualityCalculatorTest < TLDR
        def test_alpha_score
          subject = QualityCalculator.new(min_churn: 1.0, max_churn: 5.0, min_complexity: 2.0, max_complexity: 27.0)
          assert_equal 0.3169452685119259, subject.alpha_score(3.0, 7.8)
        end

        def test_beta_score
          subject = QualityCalculator.new(min_churn: 1.0, max_churn: 5.0, min_complexity: 2.0, max_complexity: 27.0)
          assert_equal 0.3405942394694261, subject.beta_score(3.0, 7.8)
        end
      end
    end
  end
end