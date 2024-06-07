# frozen_string_literal: true

require 'test_helper'

class IntegrationTest < TLDR
  FOLDER = 'tmp/test-support/txt'

  def test_that_it_has_a_version_number
    refute_nil ::ChurnVsComplexity::VERSION
  end

  def test_stubbed_engine_completes
    result = ChurnVsComplexity::Engine.concurrent(
      complexity: TestComplexityCalculator,
      churn: TestChurnCalculator,
    ).check(folder: FOLDER, since: Date.new(2000, 1, 1))

    assert_instance_of Hash, result
    assert(result.keys.all? { |k| k.is_a?(String) })
    expected_result = {
      "#{FOLDER}/abc.txt" => [3 + 4, 0],
      "#{FOLDER}/d.txt" => [1 + 4, 2],
      "#{FOLDER}/ef.txt" => [2 + 4, 5],
      "#{FOLDER}/ghij.txt" => [4 + 4, 0],
      "#{FOLDER}/klm.txt" => [3 + 4, 3],
      "#{FOLDER}/nopq.txt" => [4 + 4, 0],
      "#{FOLDER}/r.txt" => [1 + 4, 2],
      "#{FOLDER}/st.txt" => [2 + 4, 5],
      "#{FOLDER}/uvx.txt" => [3 + 4, 2],
      "#{FOLDER}/yz.txt" => [2 + 4, 6],
    }
    assert_equal expected_result, result
  end

  def test_java_graph_completes
    config = ChurnVsComplexity::Config.new(
      language: :java,
      serializer: :graph,
      excluded: %w[exclude-me me-too-also],
      graph_title: 'Integration Test, part 2',
    )
    config.validate!
    result = config.to_engine.check(folder: 'tmp/test-support/java', since: Date.new(2000, 1, 1))
    refute_nil result
    refute_empty result
  end

  def test_ruby_csv_completes
    config = ChurnVsComplexity::Config.new(
      language: :ruby,
      serializer: :csv,
    )
    config.validate!
    result = config.to_engine.check(folder: 'lib', since: Date.new(2000, 1, 1))
    refute_nil result
    refute_empty result
  end
end

class TestComplexityCalculator
  def self.folder_based? = true

  def self.calculate(folder:)
    # simulate calling an external command that prints the complexity to stdout by doing echo 42 and getting the 42 back
    ChurnVsComplexity::FileSelector::Any.select_files(folder).to_h do |file|
      `cat #{file}`
      s = stable_hash(File.basename(file))
      puts "Stable hash was #{s} for #{file}"
      c = s % 7
      puts "Complexity was #{c} for #{file}"
      [file, c]
    end
  end

  def self.stable_hash(str)
    # A simple algorithm with no dependencies that convert the presence of a character into a prime multiplier
    # and then multiplies the prime numbers to get a stable hash
    str.chars.map(&:ord).reduce(1, :*)
  end
end

module TestChurnCalculator
  def self.calculate(file:, folder:, since:)
    `cat #{file}`
    File.basename(file).length
  end
end
