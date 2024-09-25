# frozen_string_literal: true

module ChurnVsComplexity
  module FileSelector
    module Any
      def self.select_files(folder)
        included = Dir.glob("#{folder}/**/*").select { |f| File.file?(f) }
        { explicitly_excluded: [], included: }
      end
    end

    class Excluding
      def initialize(extensions, excluded)
        @extensions = extensions
        @excluded = excluded
      end

      def select_files(folder)
        were_excluded = []
        were_included = []
        Dir.glob("#{folder}/**/*").each do |f|
          if has_excluded_pattern?(f)
            were_excluded << f
          elsif has_correct_extension?(f) && File.file?(f)
            were_included << f
          end
        end
        { explicitly_excluded: were_excluded, included: were_included }
      end

      private

      def has_correct_extension?(file_path)
        @extensions.any? { |e| file_path.end_with?(e) }
      end

      def has_excluded_pattern?(file_path)
        @excluded.any? { |e| file_path.include?(e) }
      end
    end

    module Java
      def self.excluding(excluded)
        Excluding.new(['.java'], excluded)
      end
    end

    module Ruby
      def self.excluding(excluded)
        Excluding.new(['.rb'], excluded)
      end
    end

    module JavaScript
      def self.excluding(excluded)
        Excluding.new(['.js', '.jsx', '.ts', '.tsx'], excluded)
      end
    end
  end
end
