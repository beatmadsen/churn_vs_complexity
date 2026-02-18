# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require 'fileutils'

module ChurnVsComplexity
  class PythonDefaultExcludesAcceptanceTest < TLDR
    def test_should_exclude_venv_directories_by_default
      # Given: a Python project with source files and a venv directory
      Dir.mktmpdir do |dir|
        create_file(dir, 'app.py', '# source')
        create_file(dir, 'utils.py', '# source')
        create_file(dir, 'venv/lib/python3.11/site-packages/requests/__init__.py', '# vendored')
        create_file(dir, '.venv/lib/some_dep.py', '# vendored')
        create_file(dir, '__pycache__/app.cpython-311.pyc', '# bytecode')

        # When: selecting files with no user-supplied excludes
        selector = FileSelector::Python.excluding([])
        result = selector.select_files(dir)

        # Then: only source files should be included
        included_basenames = result[:included].map { |f| relative_to(f, dir) }
        assert_includes included_basenames, 'app.py', 'Source file should be included'
        assert_includes included_basenames, 'utils.py', 'Source file should be included'
        refute included_basenames.any? { |f| f.include?('venv') },
               'venv files should be excluded by default'
        refute included_basenames.any? { |f| f.include?('.venv') },
               '.venv files should be excluded by default'
        refute included_basenames.any? { |f| f.include?('__pycache__') },
               '__pycache__ files should be excluded by default'
      end
    end

    def test_should_merge_user_excludes_with_defaults
      # Given: a Python project with source files and a custom directory to exclude
      Dir.mktmpdir do |dir|
        create_file(dir, 'app.py', '# source')
        create_file(dir, 'venv/dep.py', '# vendored')
        create_file(dir, 'generated/output.py', '# generated')

        # When: user supplies additional excludes
        selector = FileSelector::Python.excluding(['generated'])
        result = selector.select_files(dir)

        # Then: both default and user excludes should apply
        included_basenames = result[:included].map { |f| relative_to(f, dir) }
        assert_includes included_basenames, 'app.py', 'Source file should be included'
        refute included_basenames.any? { |f| f.include?('venv') },
               'venv should still be excluded by default'
        refute included_basenames.any? { |f| f.include?('generated') },
               'User-specified exclude should also apply'
      end
    end

    private

    def create_file(base, relative_path, content)
      full_path = File.join(base, relative_path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, content)
    end

    def relative_to(path, base)
      path.sub("#{base}/", '')
    end
  end
end
