require 'rack/mount/regexp_with_named_groups'
require 'strscan'
require 'uri'

module Rack::Mount
  # Private utility methods used throughout Rack::Mount.
  #--
  # This module is a trash can. Try to move these functions into
  # more appropriate contexts.
  #++
  module Utils
    # Normalizes URI path.
    #
    # Strips off trailing slash and ensures there is a leading slash.
    #
    #   normalize_path("/foo")  # => "/foo"
    #   normalize_path("/foo/") # => "/foo"
    #   normalize_path("foo")   # => "/foo"
    #   normalize_path("")      # => "/"
    def normalize_path(path)
      path = "/#{path}"
      path.squeeze!(Const::SLASH)
      path.sub!(%r{/+\Z}, Const::EMPTY_STRING)
      path = Const::SLASH if path == Const::EMPTY_STRING
      path
    end
    module_function :normalize_path

    # Removes trailing nils from array.
    #
    #   pop_trailing_nils!([1, 2, 3])           # => [1, 2, 3]
    #   pop_trailing_nils!([1, 2, 3, nil, nil]) # => [1, 2, 3]
    #   pop_trailing_nils!([nil])               # => []
    def pop_trailing_nils!(ary)
      while ary.length > 0 && ary.last.nil?
        ary.pop
      end
      ary
    end
    module_function :pop_trailing_nils!

    RESERVED_PCHAR = ':@&=+$,;%'
    SAFE_PCHAR = "#{URI::REGEXP::PATTERN::UNRESERVED}#{RESERVED_PCHAR}"
    if RUBY_VERSION >= '1.9'
      UNSAFE_PCHAR = Regexp.new("[^#{SAFE_PCHAR}]", false).freeze
    else
      UNSAFE_PCHAR = Regexp.new("[^#{SAFE_PCHAR}]", false, 'N').freeze
    end

    def escape_uri(uri)
      URI.escape(uri.to_s, UNSAFE_PCHAR)
    end
    module_function :escape_uri

    # Taken from Rack 1.1.x to build nested query strings
    def build_nested_query(value, prefix = nil) #:nodoc:
      case value
      when Array
        value.map { |v|
          build_nested_query(v, "#{prefix}[]")
        }.join("&")
      when Hash
        value.map { |k, v|
          build_nested_query(v, prefix ? "#{prefix}[#{k}]" : k)
        }.join("&")
      when String
        raise ArgumentError, "value must be a Hash" if prefix.nil?
        "#{Rack::Utils.escape(prefix)}=#{Rack::Utils.escape(value)}"
      when NilClass
        Rack::Utils.escape(prefix)
      else
        if value.respond_to?(:to_param)
          build_nested_query(value.to_param.to_s, prefix)
        else
          Rack::Utils.escape(prefix)
        end
      end
    end
    module_function :build_nested_query

    def normalize_extended_expression(regexp)
      return regexp unless regexp.options & Regexp::EXTENDED != 0
      source = regexp.source
      source.gsub!(/#.+$/, '')
      source.gsub!(/\s+/, '')
      source.gsub!(/\\\//, '/')
      Regexp.compile(source)
    end
    module_function :normalize_extended_expression

    # Determines whether the regexp must match the entire string.
    #
    #   regexp_anchored?(/^foo$/) # => true
    #   regexp_anchored?(/foo/)   # => false
    #   regexp_anchored?(/^foo/)  # => false
    #   regexp_anchored?(/foo$/)  # => false
    def regexp_anchored?(regexp)
      regexp.source =~ /\A(\\A|\^).*(\\Z|\$)\Z/ ? true : false
    end
    module_function :regexp_anchored?

    # Returns static string source of Regexp if it only includes static
    # characters and no metacharacters. Otherwise the original Regexp is
    # returned.
    #
    #   extract_static_regexp(/^foo$/)      # => "foo"
    #   extract_static_regexp(/^foo\.bar$/) # => "foo.bar"
    #   extract_static_regexp(/^foo|bar$/)  # => /^foo|bar$/
    def extract_static_regexp(regexp, options = nil)
      if regexp.is_a?(String)
        regexp = Regexp.compile("\\A#{regexp}\\Z", options)
      end

      # Just return if regexp is case-insensitive
      return regexp if regexp.casefold?

      source = regexp.source
      if regexp_anchored?(regexp)
        source.sub!(/^(\\A|\^)(.*)(\\Z|\$)$/, '\2')
        unescaped_source = source.gsub(/\\/, Const::EMPTY_STRING)
        if source == Regexp.escape(unescaped_source) &&
            Regexp.compile("\\A(#{source})\\Z") =~ unescaped_source
          return unescaped_source
        end
      end
      regexp
    end
    module_function :extract_static_regexp

    if Const::SUPPORTS_NAMED_CAPTURES
      NAMED_CAPTURE_REGEXP = /\?<([^>]+)>/
    else
      NAMED_CAPTURE_REGEXP = /\?:<([^>]+)>/
    end

    # Strips shim named capture syntax and returns a clean Regexp and
    # an ordered array of the named captures.
    #
    #   extract_named_captures(/[a-z]+/)          # => /[a-z]+/, []
    #   extract_named_captures(/(?:<foo>[a-z]+)/) # => /([a-z]+)/, ['foo']
    #   extract_named_captures(/([a-z]+)(?:<foo>[a-z]+)/)
    #     # => /([a-z]+)([a-z]+)/, [nil, 'foo']
    def extract_named_captures(regexp)
      options = regexp.is_a?(Regexp) ? regexp.options : nil
      source = Regexp.compile(regexp).source
      names, scanner = [], StringScanner.new(source)

      while scanner.skip_until(/\(/)
        if scanner.scan(NAMED_CAPTURE_REGEXP)
          names << scanner[1]
        else
          names << nil
        end
      end

      names = [] unless names.any?
      source.gsub!(NAMED_CAPTURE_REGEXP, Const::EMPTY_STRING)
      return Regexp.compile(source, options), names
    end
    module_function :extract_named_captures

    class Capture < Array #:nodoc:
      attr_reader :name, :optional
      alias_method :optional?, :optional

      def initialize(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}

        @name = options.delete(:name)
        @name = @name.to_s if @name

        @optional = options.delete(:optional) || false

        super(args)
      end

      def ==(obj)
        obj.is_a?(Capture) && @name == obj.name && @optional == obj.optional && super
      end

      def optionalize!
        @optional = true
        self
      end

      def named?
        name && name != Const::EMPTY_STRING
      end

      def to_s
        source = "(#{join})"
        source << '?' if optional?
        source
      end

      def first_part
        first.is_a?(Capture) ? first.first_part : first
      end

      def last_part
        last.is_a?(Capture) ? last.last_part : last
      end
    end

    def extract_regexp_parts(regexp) #:nodoc:
      unless regexp.is_a?(RegexpWithNamedGroups)
        regexp = RegexpWithNamedGroups.new(regexp)
      end

      if regexp.source =~ /\?<([^>]+)>/
        regexp, names = extract_named_captures(regexp)
      else
        names = regexp.names
      end
      source = regexp.source

      source =~ /^(\\A|\^)/ ? source.gsub!(/^(\\A|\^)/, Const::EMPTY_STRING) :
        raise(ArgumentError, "#{source} needs to match the start of the string")

      scanner = StringScanner.new(source)
      stack = [[]]

      capture_index = 0
      until scanner.eos?
        char = scanner.getch
        cur  = stack.last

        escaped = cur.last.is_a?(String) && cur.last[-1, 1] == '\\'

        if char == '\\' && scanner.peek(1) == 'Z'
          scanner.pos += 1
          cur.push(Const::NULL)
        elsif escaped
          cur.push('') unless cur.last.is_a?(String)
          cur.last << char
        elsif char == '('
          name = names[capture_index]
          capture = Capture.new(:name => name)
          capture_index += 1
          cur.push(capture)
          stack.push(capture)
        elsif char == ')'
          capture = stack.pop
          if scanner.peek(1) == '?'
            scanner.pos += 1
            capture.optionalize!
          end
        elsif char == '$'
          cur.push(Const::NULL)
        else
          cur.push('') unless cur.last.is_a?(String)
          cur.last << char
        end
      end

      stack.pop
    end
    module_function :extract_regexp_parts
  end
end
