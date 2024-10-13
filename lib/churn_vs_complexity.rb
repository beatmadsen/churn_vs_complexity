# frozen_string_literal: true

require 'json'
require 'etc'
require 'date'
require 'time'
require 'tmpdir'

require 'digest'

module ChurnVsComplexity
  class Error < StandardError; end
  class ValidationError < Error; end

  ROOT_PATH = File.expand_path('..', __dir__)
  
  def self.tmp_dir_path(root_folder)
    folder_hash = Digest::SHA256.hexdigest(root_folder)[0..7]
    File.join(Dir.tmpdir, 'churn_vs_complexity', folder_hash)
  end
end

require_relative 'churn_vs_complexity/version'
require_relative 'churn_vs_complexity/engine'
require_relative 'churn_vs_complexity/concurrent_calculator'
require_relative 'churn_vs_complexity/file_selector'
require_relative 'churn_vs_complexity/complexity'
require_relative 'churn_vs_complexity/churn'
require_relative 'churn_vs_complexity/cli'
require_relative 'churn_vs_complexity/git_date'
require_relative 'churn_vs_complexity/complexity_validator'
require_relative 'churn_vs_complexity/language_validator'
require_relative 'churn_vs_complexity/git_strategy'
require_relative 'churn_vs_complexity/normal'
require_relative 'churn_vs_complexity/timetravel'
require_relative 'churn_vs_complexity/delta'
