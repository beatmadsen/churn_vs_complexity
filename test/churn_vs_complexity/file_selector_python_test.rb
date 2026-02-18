# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require 'fileutils'

module ChurnVsComplexity
  class FileSelectorPythonTest < TLDR
    def test_should_exclude_venv_by_default
      Dir.mktmpdir do |dir|
        create_file(dir, 'app.py')
        create_file(dir, 'venv/dep.py')

        result = FileSelector::Python.excluding([]).select_files(dir)
        included = result[:included].map { |f| File.basename(f) }

        assert_includes included, 'app.py'
        refute_includes included, 'dep.py'
      end
    end

    def test_should_exclude_dot_venv_by_default
      Dir.mktmpdir do |dir|
        create_file(dir, 'app.py')
        create_file(dir, '.venv/dep.py')

        result = FileSelector::Python.excluding([]).select_files(dir)
        included = result[:included].map { |f| File.basename(f) }

        assert_includes included, 'app.py'
        refute_includes included, 'dep.py'
      end
    end

    def test_should_exclude_pycache_by_default
      Dir.mktmpdir do |dir|
        create_file(dir, 'app.py')
        create_file(dir, '__pycache__/app.cpython-311.py')

        result = FileSelector::Python.excluding([]).select_files(dir)
        filenames = result[:included].map { |f| File.basename(f) }

        assert_equal ['app.py'], filenames
      end
    end

    def test_should_merge_user_excludes_with_defaults
      Dir.mktmpdir do |dir|
        create_file(dir, 'app.py')
        create_file(dir, 'venv/dep.py')
        create_file(dir, 'generated/out.py')

        result = FileSelector::Python.excluding(['generated']).select_files(dir)
        included = result[:included].map { |f| File.basename(f) }

        assert_equal ['app.py'], included
      end
    end

    private

    def create_file(base, relative_path)
      full_path = File.join(base, relative_path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, '# python')
    end
  end
end
