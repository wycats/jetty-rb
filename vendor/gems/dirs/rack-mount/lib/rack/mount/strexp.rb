require 'strscan'

module Rack::Mount
  class Strexp < Regexp
    # Parses segmented string expression and converts it into a Regexp
    #
    #   Strexp.compile('foo')
    #     # => %r{\Afoo\Z}
    #
    #   Strexp.compile('foo/:bar', {}, ['/'])
    #     # => %r{\Afoo/(?<bar>[^/]+)\Z}
    #
    #   Strexp.compile(':foo.example.com')
    #     # => %r{\A(?<foo>.+)\.example\.com\Z}
    #
    #   Strexp.compile('foo/:bar', {:bar => /[a-z]+/}, ['/'])
    #     # => %r{\Afoo/(?<bar>[a-z]+)\Z}
    #
    #   Strexp.compile('foo(.:extension)')
    #     # => %r{\Afoo(\.(?<extension>.+))?\Z}
    #
    #   Strexp.compile('src/*files')
    #     # => %r{\Asrc/(?<files>.+)\Z}
    def initialize(str, requirements = {}, separators = [])
      return super(str) if str.is_a?(Regexp)

      re = Regexp.escape(str)
      requirements = requirements ? requirements.dup : {}

      normalize_requirements!(requirements, separators)
      parse_dynamic_segments!(re, requirements)
      parse_optional_segments!(re)

      super("\\A#{re}\\Z")
    end

    private
      def normalize_requirements!(requirements, separators)
        requirements.each do |key, value|
          if value.is_a?(Regexp)
            if regexp_has_modifiers?(value)
              requirements[key] = value
            else
              requirements[key] = value.source
            end
          else
            requirements[key] = Regexp.escape(value)
          end
        end
        requirements.default ||= separators.any? ?
          "[^#{separators.join}]+" : '.+'
        requirements
      end

      def parse_dynamic_segments!(str, requirements)
        re, pos, scanner = '', 0, StringScanner.new(str)
        while scanner.scan_until(/(:|\\\*)([a-zA-Z_]\w*)/)
          pre, pos = scanner.pre_match[pos..-1], scanner.pos
          if pre =~ /(.*)\\\\\Z/
            re << $1 + scanner.matched
          else
            name = scanner[2].to_sym
            requirement = scanner[1] == ':' ?
              requirements[name] : '.+'
            re << pre + Const::REGEXP_NAMED_CAPTURE % [name, requirement]
          end
        end
        re << scanner.rest
        str.replace(re)
      end

      def parse_optional_segments!(str)
        re, pos, scanner = '', 0, StringScanner.new(str)
        while scanner.scan_until(/\\\(|\\\)/)
          pre, pos = scanner.pre_match[pos..-1], scanner.pos
          if pre =~ /(.*)\\\\\Z/
            re << $1 + scanner.matched
          elsif scanner.matched == '\\('
            # re << pre + '(?:'
            re << pre + '('
          elsif scanner.matched == '\\)'
            re << pre + ')?'
          end
        end
        re << scanner.rest
        str.replace(re)
      end

      def regexp_has_modifiers?(regexp)
        regexp.options & (Regexp::IGNORECASE | Regexp::EXTENDED) != 0
      end
  end
end
