# frozen_string_literal: true

require 'test_helper'
require 'securerandom'

class TimetravelIntegrationTest < TLDR
  def test_ruby_csv_completes
    config = ChurnVsComplexity::Timetravel::Config.new(
      language: :ruby,
      serializer: :csv,
      jump_days: 3_000,
      relative_period: :month,
      factory: FactoryStub.new,
    )
    config.validate!
    result = config.checker.check(folder: ChurnVsComplexity::ROOT_PATH)
    refute_nil result
    refute_empty result
  end

  def test_ruby_graph_completes
    config = ChurnVsComplexity::Timetravel::Config.new(
      language: :ruby,
      serializer: :graph,
      jump_days: 3_000,
      relative_period: :quarter,
      factory: FactoryStub.new,
    )
    config.validate!
    result = config.checker.check(folder: ChurnVsComplexity::ROOT_PATH)
    refute_nil result
    refute_empty result
  end

  class FactoryStub
    F = ChurnVsComplexity::Timetravel::Factory

    # Delegate specific methods to F
    delegate :git_strategy, :worker, :pipe, to: :F

    def initialize
      @id = SecureRandom.hex(4)
    end

    def worktree(**args) = TestWorktree.new(id: @id, **args)
  end

  class TestWorktree < ChurnVsComplexity::Timetravel::Worktree
    def initialize(id:, **args)
      super(**args)
      @id = id
    end

    protected

    # Dedicated folder for each test, to ensure isolation
    def tt_folder
      @tt_folder ||= File.join(super, @id)
    end
  end
end
