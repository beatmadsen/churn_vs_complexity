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
      def initialize(extensions, excluded, convert_to_absolute_path = false)
        @extensions = extensions
        @excluded = excluded
        @convert_to_absolute_path = convert_to_absolute_path
      end

      def select_files(folder)
        were_excluded = []
        were_included = []
        cs = candidates(folder)
        cs.each do |f|
          if has_excluded_pattern?(f)
            were_excluded << f
          elsif has_correct_extension?(f) && File.file?(f)
            were_included << f
          end
        end
        if @convert_to_absolute_path
          were_excluded.map! { |f| File.absolute_path(f) }
          were_included.map! { |f| File.absolute_path(f) }
        end
        { explicitly_excluded: were_excluded, included: were_included }
      end

      protected

      def candidates(folder)
        Dir.glob("#{folder}/**/*")
      end

      private

      def has_correct_extension?(file_path)
        @extensions.any? { |e| file_path.end_with?(e) }
      end

      def has_excluded_pattern?(file_path)
        @excluded.any? { |e| file_path.include?(e) }
      end
    end

    class Predefined < Excluding
      def initialize(included:, extensions:, excluded:, convert_to_absolute_path: false)
        super(extensions, excluded, convert_to_absolute_path)
        @included = included
      end

      protected

      def candidates(*) = @included
    end

    module Java
      def self.excluding(excluded)
        Excluding.new(['.java'], excluded)
      end

      def self.predefined(included:, excluded:)
        Predefined.new(included:, extensions: ['.java'], excluded:)
      end
    end

    module Ruby
      def self.excluding(excluded)
        Excluding.new(['.rb'], excluded)
      end

      def self.predefined(included:, excluded:)
        Predefined.new(included:, extensions: ['.rb'], excluded:)
      end
    end

    module JavaScript
      def self.excluding(excluded)
        Excluding.new(['.js', '.jsx', '.ts', '.tsx'], excluded, true)
      end

      def self.predefined(included:, excluded:)
        Predefined.new(included:, extensions: ['.js', '.jsx', '.ts', '.tsx'], excluded:, convert_to_absolute_path: true)
      end
    end
  end
end
