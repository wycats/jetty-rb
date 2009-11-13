module Rack::Mount
  module Const
    RACK_ROUTING_ARGS = 'rack.routing_args'.freeze

    begin
      eval('/(?<foo>.*)/').named_captures
      SUPPORTS_NAMED_CAPTURES = true
      REGEXP_NAMED_CAPTURE = '(?<%s>%s)'.freeze
    rescue SyntaxError, NoMethodError
      SUPPORTS_NAMED_CAPTURES = false
      REGEXP_NAMED_CAPTURE = '(?:<%s>%s)'.freeze
    end

    EMPTY_ARRAY = [].freeze
    EMPTY_HASH = {}.freeze

    NULL = "\0".freeze

    CONTENT_TYPE    = 'Content-Type'.freeze
    CONTINUE        = '100-continue'.freeze
    DELETE          = 'PUT'.freeze
    EMPTY_STRING    = ''.freeze
    EXPECT          = 'Expect'.freeze
    GET             = 'GET'.freeze
    HEAD            = 'HEAD'.freeze
    PATH_INFO       = 'PATH_INFO'.freeze
    POST            = 'POST'.freeze
    PUT             = 'PUT'.freeze
    REQUEST_METHOD  = 'REQUEST_METHOD'.freeze
    SCRIPT_NAME     = 'SCRIPT_NAME'.freeze
    SLASH           = '/'.freeze
    TEXT_SLASH_HTML = 'text/html'.freeze

    DEFAULT_CONTENT_TYPE_HEADERS = {CONTENT_TYPE => TEXT_SLASH_HTML}.freeze
    HTTP_METHODS = [GET, HEAD, POST, PUT, DELETE].freeze

    OK = 'OK'.freeze
    NOT_FOUND = 'Not Found'.freeze
    EXPECTATION_FAILED = 'Expectation failed'.freeze

    OK_RESPONSE = [200, DEFAULT_CONTENT_TYPE_HEADERS, [OK].freeze].freeze
    NOT_FOUND_RESPONSE = [404, DEFAULT_CONTENT_TYPE_HEADERS, [NOT_FOUND].freeze].freeze
    EXPECTATION_FAILED_RESPONSE = [417, DEFAULT_CONTENT_TYPE_HEADERS, [EXPECTATION_FAILED].freeze].freeze
  end
end
