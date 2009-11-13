module Rack::Mount
  module Analysis
    module Splitting
      class Key < Array
        def initialize(method, index, separators)
          replace([method, index, separators])
        end

        def self.split(value, separator_pattern)
          keys = value.split(separator_pattern)
          keys.shift if keys[0] == Const::EMPTY_STRING
          keys << Const::NULL
          keys
        end

        def call(cache, obj)
          (cache[self[0]] ||= self.class.split(obj.send(self[0]), self[2]))[self[1]]
        end

        def call_source(cache, obj)
          "(#{cache}[:#{self[0]}] ||= Analysis::Splitting::Key.split(#{obj}.#{self[0]}, #{self[2].inspect}))[#{self[1]}]"
        end
      end

      def clear
        @boundaries = {}
        super
      end

      def <<(key)
        super
        key.each_pair do |k, v|
          analyze_capture_boundaries(v, @boundaries[k] ||= Histogram.new)
        end
      end

      def separators(key)
        @boundaries[key].select_upper
      end

      def process_key(requirements, method, requirement)
        separators = separators(method)
        if requirement.is_a?(Regexp) && separators.any?
          generate_split_keys(requirement, separators).each_with_index do |value, index|
            requirements[Key.new(method, index, Regexp.union(*separators))] = value
          end
        else
          super
        end
      end

      private
        def analyze_capture_boundaries(regexp, boundaries) #:nodoc:
          return boundaries unless regexp.is_a?(Regexp)

          parts = Utils.extract_regexp_parts(regexp) rescue []
          parts.each_with_index do |part, index|
            break if part == Const::NULL

            if index > 0
              previous = parts[index-1]
              if previous.is_a?(Utils::Capture)
                previous = Utils.extract_static_regexp(previous.last_part) rescue nil
              end
              boundaries << previous[-1..-1] if previous.is_a?(String)
            end

            if index < parts.length
              following = parts[index+1]
              if following.is_a?(Utils::Capture)
                following = Utils.extract_static_regexp(following.first_part) rescue nil
              end
              if following.is_a?(String) && following != Const::NULL
                boundaries << following[0..0] == '\\' ? following[1..1] : following[0..0]
              end
            end
          end
          boundaries
        end

        def generate_split_keys(regexp, separators) #:nodoc:
          escaped_separators = separators.map { |s| Regexp.escape(s) }
          separators_regexp = Regexp.union(*escaped_separators)
          segments, previous = [], nil
          regexp_options = regexp.options

          begin
            Utils.extract_regexp_parts(regexp).each do |part|
              if part.respond_to?(:optional?) && part.optional?
                if escaped_separators.include?(part.first)
                  append_to_segments!(segments, previous, separators, regexp_options)
                end

                raise ArgumentError
              end

              append_to_segments!(segments, previous, separators, regexp_options)
              previous = nil

              if part == Const::NULL
                segments << Const::NULL
                raise ArgumentError
              end

              if part.is_a?(Utils::Capture)
                source = part.map { |p| p.to_s }.join
                append_to_segments!(segments, source, separators, regexp_options)
              else
                parts = part.split(separators_regexp)
                parts.shift if parts[0] == Const::EMPTY_STRING
                previous = parts.pop
                parts.each { |p| append_to_segments!(segments, p, separators, regexp_options) }
              end
            end

            append_to_segments!(segments, previous, separators, regexp_options)
          rescue ArgumentError
            # generation failed somewhere, but lets take what we can get
          end

          while segments.length > 0 && (segments.last.nil? || segments.last == '')
            segments.pop
          end

          segments
        end

        def append_to_segments!(segments, s, separators, regexp_options) #:nodoc:
          return unless s
          separators.each do |separator|
            if s.gsub(/\[[^\]]+\]/, '').include?(separator)
              raise ArgumentError
            end

            if Regexp.compile("\\A#{s}\\Z") =~ separator
              raise ArgumentError
            end
          end

          static = Utils.extract_static_regexp(s, regexp_options)
          segments << (static.is_a?(String) ? static : static)
        end
      end
  end
end
