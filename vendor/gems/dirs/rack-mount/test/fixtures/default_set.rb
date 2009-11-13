DefaultSet = Rack::Mount::RouteSet.new do |set|
  if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
    re = eval('%r{^/(?<controller>[a-z0-9]+)(/(?<action>[a-z0-9]+)(/(?<id>[a-z0-9]+)(\.(?<format>[a-z]+))?)?)?$}')
    set.add_route(EchoApp, :path_info => re)
  else
    set.add_route(EchoApp, :path_info => %r{^/(?:<controller>[a-z0-9]+)(/(?:<action>[a-z0-9]+)(/(?:<id>[a-z0-9]+)(\.(?:<format>[a-z]+))?)?)?$})
  end
end
