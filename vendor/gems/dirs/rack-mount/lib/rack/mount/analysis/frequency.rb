module Rack::Mount
  module Analysis
    class Frequency #:nodoc:
      extend Mixover

      def initialize(*keys)
        clear
        keys.each { |key| self << key }
      end

      def clear
        @raw_keys = []
        @key_frequency = Analysis::Histogram.new
        self
      end

      def <<(key)
        raise ArgumentError unless key.is_a?(Hash)
        @raw_keys << key
        nil
      end

      def possible_keys
        @possible_keys ||= begin
          @raw_keys.map do |key|
            key.inject({}) { |requirements, (method, requirement)|
              process_key(requirements, method, requirement)
              requirements
            }
          end
        end
      end

      def process_key(requirements, method, requirement)
        if requirement.is_a?(Regexp)
          requirements[method] = Utils.extract_static_regexp(requirement)
        else
          requirements[method] = requirement
        end
      end

      def report
        @report ||= begin
          possible_keys.each { |keys| keys.each_pair { |key, _| @key_frequency << key } }
          return [] if @key_frequency.count <= 1
          @key_frequency.select_upper
        end
      end
    end
  end
end
