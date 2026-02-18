# frozen_string_literal: true

require 'test_helper'
require 'open3'

module ChurnVsComplexity
  class GocognitStderrLeakAcceptanceTest < TLDR
    def test_should_not_leak_stderr_when_checking_go_dependencies
      # Given: a command runner that records the command check_dependencies! passes
      recorded_cmd = nil
      Complexity::GoCalculator.command_runner = lambda { |cmd|
        recorded_cmd = cmd
        ['', Data.define(:success?, :exitstatus).new(true, 0)]
      }

      # When: check_dependencies! is called
      Complexity::GoCalculator.check_dependencies!

      # Then: the command should redirect stderr to prevent gocognit help text
      #        from polluting the terminal (gocognit --help writes to stderr)
      assert_match(/2>&1/, recorded_cmd,
                   'check_dependencies! should redirect stderr so gocognit help text does not leak to terminal')
    ensure
      Complexity::GoCalculator.command_runner = nil
    end

    def test_should_capture_stderr_output_via_redirect
      # Given: a command that produces stderr output, run through the redirect pattern
      #        used by check_dependencies! (gocognit --help 2>&1)
      stdout, _status = Open3.capture2('ruby -e "STDERR.puts %(leaked)" 2>&1')

      # Then: stderr output should appear in captured stdout (redirected by 2>&1)
      assert_match(/leaked/, stdout,
                   '2>&1 redirect should capture stderr into stdout')
    end
  end
end
