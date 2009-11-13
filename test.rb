$:.push File.join(Dir.pwd, "lib")
require "jetty"

require "#{File.dirname(__FILE__)}/vendor/gems/environment"
require "rack/mount"

class FooApp
  def call(env)
    [200, {"Content-Type" => "text/html"},
      ["<h1>Hello world from FooApp #{env["rack.routing_args"].inspect}</h1>"]]
  end
end

routes = Rack::Mount::RouteSet.new do |set|
  set.add_route(FooApp.new, :path_info => Rack::Mount::Strexp.new("/:foo"))
  set.add_route(proc {|env| [200, {}, ["DEFAULT"]]}, :path => "/")
end

using(org.eclipse.jetty => "Jetty") do
  # org.eclipse.jetty.server.Server
  Server::Server.start_rack(routes)
end