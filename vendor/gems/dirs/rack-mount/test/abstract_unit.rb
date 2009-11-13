begin
  require 'rack'
rescue LoadError
  warn "Loading rubygems"
  require 'rubygems'
end

require 'test/unit'
require 'rack/mount'
require 'fixtures'

module ControllerConstants
  def const_missing(name)
    if name.to_s =~ /Controller$/
      const_set(name, EchoApp)
    else
      super
    end
  end
end

module Account
  extend ControllerConstants
end

Object.extend(ControllerConstants)

class Test::Unit::TestCase
  private
    def set_included_modules
      class << @app; included_modules; end
    end

    def env
      @env
    end

    def response
      @response
    end

    def routing_args_key
      Rack::Mount::Const::RACK_ROUTING_ARGS
    end

    def routing_args
      @env[routing_args_key]
    end

    def get(path, options = {})
      process(path, options.merge(:method => 'GET'))
    end

    def post(path, options = {})
      process(path, options.merge(:method => 'POST'))
    end

    def put(path, options = {})
      process(path, options.merge(:method => 'PUT'))
    end

    def delete(path, options = {})
      process(path, options.merge(:method => 'DELETE'))
    end

    def process(path, options = {})
      @path = path

      require 'rack/mock'
      env = Rack::MockRequest.env_for(path, options)
      @response = @app.call(env)

      if @response && @response[0] == 200
        @env = YAML.load(@response[2][0])
      else
        @env = nil
      end
    end

    def assert_success
      assert(@response)
      assert_equal(200, @response[0], "No route matches #{@path.inspect}")
    end

    def assert_not_found
      assert(@response)
      assert_equal(404, @response[0])
    end
end
