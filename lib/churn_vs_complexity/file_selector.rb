# frozen_string_literal: true

module ChurnVsComplexity
  module FileSelector
    module Any
      def self.select_files(folder)
        Dir.glob("#{folder}/**/*").select { |f| File.file?(f) }
      end
    end

    class Excluding
      def initialize(extensions, excluded)
        @extensions = extensions
        @excluded = excluded
      end

      def select_files(folder)
        Dir.glob("#{folder}/**/*").select do |f|
          !has_excluded_pattern?(f) && has_correct_extension?(f) && File.file?(f)
        end
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
  end
end
