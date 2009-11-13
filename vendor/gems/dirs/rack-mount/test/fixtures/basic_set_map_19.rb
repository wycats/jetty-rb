BasicSetMap = Proc.new do |set|
  set.add_route(EchoApp, { :path_info => '/people', :request_method => 'GET' }, { :controller => 'people', :action => 'index' })
  set.add_route(EchoApp, { :path_info => '/people', :request_method => 'POST' }, { :controller => 'people', :action => 'create' })
  set.add_route(EchoApp, { :path_info => '/people/new', :request_method => 'GET' }, { :controller => 'people', :action => 'new' })
  set.add_route(EchoApp, { :path_info => %r{^/people/(?<id>[^/]+)/edit$}, :request_method => 'GET' }, { :controller => 'people', :action => 'edit' })
  set.add_route(EchoApp, { :path_info => %r{^/people/(?<id>[^/]+)$}, :request_method => 'GET' }, { :controller => 'people', :action => 'show' }, :person)
  set.add_route(EchoApp, { :path_info => %r{^/people/(?<id>[^/]+)$}, :request_method => 'PUT' }, { :controller => 'people', :action => 'update' })
  set.add_route(EchoApp, { :path_info => %r{^/people/(?<id>[^/]+)$}, :request_method => 'DELETE' }, { :controller => 'people', :action => 'destroy' })

  set.add_route(EchoApp, { :path_info => '/' }, { :controller => 'homepage' }, :root)

  set.add_route(EchoApp, { :path_info => %r{^/ws/(?<controller>[a-z]+)(/(?<action>[a-z]+)(/(?<id>[0-9]+))?)?$} }, { :ws => true })

  set.add_route(EchoApp, { :path_info => %r{^/geocode/(?<postalcode>\d{5}(-\d{4})?)$} }, { :controller => 'geocode', :action => 'show' }, :geocode)
  set.add_route(EchoApp, { :path_info => %r{^/geocode2/(?<postalcode>\d{5}(-\d{4})?)$} }, { :controller => 'geocode', :action => 'show' }, :geocode2)

  set.add_route(EchoApp, { :path_info => '/login', :request_method => 'GET' }, { :controller => 'sessions', :action => 'new' }, :login)
  set.add_route(EchoApp, { :path_info => '/login', :request_method => 'POST' }, { :controller => 'sessions', :action => 'create' })
  set.add_route(EchoApp, { :path_info => '/logout', :request_method => 'DELETE' }, { :controller => 'sessions', :action => 'destroy' }, :logout)

  set.add_route(EchoApp, { :path_info => %r{^/global/(?<action>[a-z0-9]+)$} }, { :controller => 'global' })
  set.add_route(EchoApp, { :path_info => '/global/export' }, { :controller => 'global', :action => 'export' }, :export_request)
  set.add_route(EchoApp, { :path_info => '/global/hide_notice' }, { :controller => 'global', :action => 'hide_notice' }, :hide_notice)
  set.add_route(EchoApp, { :path_info => %r{^/export/(?<id>[a-z0-9]+)/(?<file>.*)$} }, { :controller => 'global', :action => 'export' }, :export_download)

  set.add_route(EchoApp, { :path_info => '/account/subscription', :request_method => 'GET' }, { :controller => 'account/subscription', :action => 'index' })
  set.add_route(EchoApp, { :path_info => '/account/subscription', :request_method => 'POST' }, { :controller => 'account/subscription', :action => 'create' })
  set.add_route(EchoApp, { :path_info => '/account/subscription/new', :request_method => 'GET' }, { :controller => 'account/subscription', :action => 'new' })
  set.add_route(EchoApp, { :path_info => %r{^/account/subscription/(?<id>[a-z0-9]+)/edit$}, :request_method => 'GET' }, { :controller => 'account/subscription', :action => 'edit' })
  set.add_route(EchoApp, { :path_info => %r{^/account/subscription/(?<id>[a-z0-9]+)$}, :request_method => 'GET' }, { :controller => 'account/subscription', :action => 'show' })
  set.add_route(EchoApp, { :path_info => %r{^/account/subscription/(?<id>[a-z0-9]+)$}, :request_method => 'PUT' }, { :controller => 'account/subscription', :action => 'update' })
  set.add_route(EchoApp, { :path_info => %r{^/account/subscription/(?<id>[a-z0-9]+)$}, :request_method => 'DELETE' }, { :controller => 'account/subscription', :action => 'destroy' })

  set.add_route(EchoApp, { :path_info => '/account/credit', :request_method => 'GET' }, { :controller => 'account/credit', :action => 'index' })
  set.add_route(EchoApp, { :path_info => '/account/credit', :request_method => 'POST' }, { :controller => 'account/credit', :action => 'create' })
  set.add_route(EchoApp, { :path_info => '/account/credit/new', :request_method => 'GET' }, { :controller => 'account/credit', :action => 'new' })
  set.add_route(EchoApp, { :path_info => %r{^/account/credit/(?<id>[a-z0-9]+)/edit$}, :request_method => 'GET' }, { :controller => 'account/credit', :action => 'edit' })
  set.add_route(EchoApp, { :path_info => %r{^/account/credit/(?<id>[a-z0-9]+)$}, :request_method => 'GET' }, { :controller => 'account/credit', :action => 'show' })
  set.add_route(EchoApp, { :path_info => %r{^/account/credit/(?<id>[a-z0-9]+)$}, :request_method => 'PUT' }, { :controller => 'account/credit', :action => 'update' })
  set.add_route(EchoApp, { :path_info => %r{^/account/credit/(?<id>[a-z0-9]+)$}, :request_method => 'DELETE' }, { :controller => 'account/credit', :action => 'destroy' })

  set.add_route(EchoApp, { :path_info => '/account/credit_card', :request_method => 'GET' }, { :controller => 'account/credit_card', :action => 'index' })
  set.add_route(EchoApp, { :path_info => '/account/credit_card', :request_method => 'POST' }, { :controller => 'account/credit_card', :action => 'create' })
  set.add_route(EchoApp, { :path_info => '/account/credit_card/new', :request_method => 'GET' }, { :controller => 'account/credit_card', :action => 'new' })
  set.add_route(EchoApp, { :path_info => %r{^/account/credit_card/(?<id>[a-z0-9]+)/edit$}, :request_method => 'GET' }, { :controller => 'account/credit_card', :action => 'edit' })
  set.add_route(EchoApp, { :path_info => %r{^/account/credit_card/(?<id>[a-z0-9]+)$}, :request_method => 'GET' }, { :controller => 'account/credit_card', :action => 'show' })
  set.add_route(EchoApp, { :path_info => %r{^/account/credit_card/(?<id>[a-z0-9]+)$}, :request_method => 'PUT' }, { :controller => 'account/credit_card', :action => 'update' })
  set.add_route(EchoApp, { :path_info => %r{^/account/credit_card/(?<id>[a-z0-9]+)$}, :request_method => 'DELETE' }, { :controller => 'account/credit_card', :action => 'destroy' })

  set.add_route(EchoApp, { :path_info => %r{^/account2(/(?<action>[a-z]+))?$} }, { :controller => 'account2', :action => 'subscription' })

  set.add_route(EchoApp, :path_info => %r{^/(?<controller>admin/users|admin/groups)$})

  set.add_route(EchoApp, { :path_info => %r{^/feed/(?<kind>[a-z]+)$} }, { :controller => 'feed', :kind => 'rss' }, :feed)
  set.add_route(EchoApp, { :path_info => %r{^/feed2(\.(?<format>[a-z]+))?$} }, { :controller => 'feed2', :format => 'rss' }, :feed2)

  set.add_route(EchoApp, { :path_info => Rack::Mount::Utils.normalize_path('foo') }, { :controller => 'foo', :action => 'index' })
  set.add_route(EchoApp, { :path_info => Rack::Mount::Utils.normalize_path('foo/bar') }, { :controller => 'foo_bar', :action => 'index' })
  set.add_route(EchoApp, { :path_info => Rack::Mount::Utils.normalize_path('/baz') }, { :controller => 'baz', :action => 'index' })

  set.add_route(EchoApp, { :path_info => Rack::Mount::Utils.normalize_path('/slashes/trailing/') }, { :controller => 'slash', :action => 'trailing' })
  set.add_route(EchoApp, { :path_info => Rack::Mount::Utils.normalize_path('//slashes/repeated') }, { :controller => 'slash', :action => 'repeated' })

  set.add_route(EchoApp, { :path_info => '/ssl', :scheme => 'http' }, { :controller => 'ssl', :action => 'nonssl' })
  set.add_route(EchoApp, { :path_info => '/ssl', :scheme => 'https' }, { :controller => 'ssl', :action => 'ssl' })
  set.add_route(EchoApp, { :path_info => '/method', :request_method => /get|post/i }, { :controller => 'method', :action => 'index' })
  set.add_route(EchoApp, { :path_info => '/host', :host => %r{^(?<account>[0-9a-z]+)\.backpackit\.com$} }, { :controller => 'account' })

  set.add_route(EchoApp, { :path_info => %r{^/optional/index(\.(?<format>[a-z]+))?$} }, { :controller => 'optional', :action => 'index' })

  set.add_route(EchoApp, { :path_info => %r{^/regexp/foos?/(?<action>bar|baz)/(?<id>[a-z0-9]+)$} }, { :controller => 'foo' })
  set.add_route(EchoApp, { :path_info => %r{^/regexp/bar/(?<action>[a-z]+)/(?<id>[0-9]+)$} }, { :controller => 'foo' }, :complex_regexp)
  set.add_route(EchoApp, { :path_info => %r{^/regexp/baz/[a-z]+/[0-9]+$} }, { :controller => 'foo' }, :complex_regexp_fail)
  set.add_route(EchoApp, { :path_info => %r{^/escaped/\(foo\)$} }, { :controller => 'escaped/foo' }, :escaped_optional_capture)
  set.add_route(EchoApp, { :path_info => %r{^/ignorecase/foo$}i }, { :controller => 'ignorecase' })
  set.add_route(EchoApp, { :path_info => (/^\/extended\/ # comment
                                            foo # bar
                                            $/x) }, { :controller => 'extended' })

  set.add_route(EchoApp, { :path_info => %r{^/uri_escaping/(?<value>.+)$} }, { :controller => 'uri_escaping' })

  set.add_route(EchoApp, { :path_info => %r{^/files/(?<files>.*)$} }, { :controller => 'files', :action => 'index' })

  set.add_route(EchoApp, :path_info => %r{^/pages/(?<page_id>[0-9]+)/(?<controller>[a-z0-9]+)(/(?<action>[a-z0-9]+)(/(?<id>[a-z0-9]+)(\.(?<format>[a-z]+))?)?)?$})
  set.add_route(EchoApp, { :path_info => %r{^/params_with_defaults(/(?<controller>[a-z0-9]+))?$} }, { :params_with_defaults => true, :controller => 'foo' })
  set.add_route(EchoApp, :path_info => %r{^/default/(?<controller>[a-z0-9]+)(/(?<action>[a-z0-9]+)(/(?<id>[a-z0-9]+)(\.(?<format>[a-z]+))?)?)?$})
  set.add_route(EchoApp, { :request_method => 'DELETE' }, { :controller => 'global', :action => 'destroy' })

  set.add_route(lambda { |env| Rack::Mount::Const::EXPECTATION_FAILED_RESPONSE }, { :path_info => %r{^/prefix} })
  set.add_route(DefaultSet, { :path_info => %r{^/prefix} }, {}, :prefix)

  set.add_route(EchoApp, { :path_info => %r{^/(.*)/star$} }, { :controller => 'star' })
end
