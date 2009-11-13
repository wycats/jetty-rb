require "jetty/jruby_ext/packages"

%w(ajp annotations client continuation deploy http
io jmx jndi plus policy rewrite security server
servlet servlets util webapp xml).each do |jar|
  load_jar "jetty/jar/jetty-#{jar}-7.0.0.v20091005"
end

load_jar "jetty/jar/servlet-api-2.5"

import org.eclipse.jetty.server.handler.AbstractHandler
import javax.servlet.http.HttpServletResponse

class LazyRackEnv
  def initialize(request)
    @request = request
  end

  def [](key)
    if key =~ /^HTTP_(.*)/
      @request.header($1)
    else
      send(key)
    end
  rescue NoMethodError
  end

  def REQUEST_METHOD
    @request.method
  end

  def SCRIPT_NAME
    ""
  end

  def PATH_INFO
    @request.path_info
  end

  def QUERY_STRING
    @request.query_string
  end

  def SERVER_NAME
    @request.server_name
  end

  def SERVER_PORT
    @request.server_port
  end
end

class RackHandler < AbstractHandler
  attr_accessor :app

  def self.build(endpoint)
    new.tap {|h| h.app = endpoint }
  end

  def handle(target, base_request, request, response)
    lazy_env = LazyRackEnv.new(request)
    env = Hash.new {|h,k| h[k] = lazy_env[k] }

    status, headers, body = @app.call(env)
    response.status = status.to_i
    base_request.handled = true

    headers.each do |header, value|
      response.set_header header, value
    end

    writer = response.writer
    body.each { |part| writer.print part }
  end
end

using(org.eclipse.jetty => "Jetty") do
  # org.eclipse.jetty.server.Server
  class Server::Server
    # org.eclipse.jetty.util.thread
    include Util::Thread

    def self.start_rack(endpoint, options = {})
      new(options[:port] || 8080).tap do |server|
        server.thread_pool = QueuedThreadPool.new(20)
        server.handler = RackHandler.build(endpoint)
        server.start
        server.join
      end
    end
  end
end