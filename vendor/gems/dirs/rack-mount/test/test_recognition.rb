# encoding: utf-8

require 'abstract_unit'

class TestRecognition < Test::Unit::TestCase
  def setup
    @app = BasicSet
    assert !set_included_modules.include?(Rack::Mount::Recognition::CodeGeneration)
  end

  def test_path
    get '/foo'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'index' }, routing_args)

    post '/foo'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'index' }, routing_args)

    put '/foo'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'index' }, routing_args)

    delete '/foo'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'index' }, routing_args)
  end

  def test_nested_path
    get '/foo/bar'
    assert_success
    assert_equal({ :controller => 'foo_bar', :action => 'index' }, routing_args)
  end

  def test_path_mapped_with_leading_slash
    get '/baz'
    assert_success
    assert_equal({ :controller => 'baz', :action => 'index' }, routing_args)
  end

  def test_path_does_get_shadowed
    get '/people'
    assert_success
    assert_equal({ :controller => 'people', :action => 'index' }, routing_args)

    get '/people/new'
    assert_success
    assert_equal({ :controller => 'people', :action => 'new' }, routing_args)
  end

  def test_root_path
    get '/'
    assert_success
    assert_equal({ :controller => 'homepage' }, routing_args)
  end

  def test_another_with_controller_scope
    get '/login'
    assert_success
    assert_equal({ :controller => 'sessions', :action => 'new' }, routing_args)

    post '/login'
    assert_success
    assert_equal({ :controller => 'sessions', :action => 'create' }, routing_args)

    get '/logout'
    assert_not_found

    delete '/logout'
    assert_success
    assert_equal({ :controller => 'sessions', :action => 'destroy' }, routing_args)
  end

  def test_only_method_condition
    delete '/all'
    assert_success
    assert_equal({ :controller => 'global', :action => 'destroy' }, routing_args)

    get '/all'
    assert_not_found
  end

  def test_schema_condition
    get '/ssl', 'rack.url_scheme' => 'http'
    assert_success
    assert_equal({ :controller => 'ssl', :action => 'nonssl' }, routing_args)

    get '/ssl', 'rack.url_scheme' => 'https'
    assert_success
    assert_equal({ :controller => 'ssl', :action => 'ssl' }, routing_args)
  end

  def test_host_condition
    get '/host', 'HTTP_HOST' => '37s.backpackit.com'
    assert_success
    assert_equal({ :controller => 'account', :account => '37s' }, routing_args)

    get '/host', 'HTTP_HOST' => 'josh.backpackit.com'
    assert_success
    assert_equal({ :controller => 'account', :account => 'josh' }, routing_args)
  end

  def test_slashes
    get '/slashes/trailing/'
    assert_success
    assert_equal({ :controller => 'slash', :action => 'trailing' }, routing_args)

    get '/slashes/trailing'
    assert_success
    assert_equal({ :controller => 'slash', :action => 'trailing' }, routing_args)

    get '/slashes/repeated'
    assert_success
    assert_equal({ :controller => 'slash', :action => 'repeated' }, routing_args)
  end

  def test_not_found
    get '/admin/widgets/show/random'
    assert_not_found
  end

  def test_extracts_id
    get '/people/1'
    assert_success
    assert_equal({ :controller => 'people', :action => 'show', :id => '1' }, routing_args)

    put '/people/1'
    assert_success
    assert_equal({ :controller => 'people', :action => 'update', :id => '1' }, routing_args)

    delete '/people/1'
    assert_success
    assert_equal({ :controller => 'people', :action => 'destroy', :id => '1' }, routing_args)

    get '/people/2/edit'
    assert_success
    assert_equal({ :controller => 'people', :action => 'edit', :id => '2' }, routing_args)
  end

  def test_requirements
    get '/geocode/60614'
    assert_success
    assert_equal({ :controller => 'geocode', :action => 'show', :postalcode => '60614' }, routing_args)

    get '/geocode2/60614'
    assert_success
    assert_equal({ :controller => 'geocode', :action => 'show', :postalcode => '60614' }, routing_args)
  end

  def test_path_with_globbing
    get '/files/images/photo.jpg'
    assert_success

    assert_equal({ :controller => 'files', :action => 'index', :files => 'images/photo.jpg' }, routing_args)
  end

  def test_with_controller_scope
    get '/global/index'
    assert_success
    assert_equal({ :controller => 'global', :action => 'index' }, routing_args)

    get '/global/show'
    assert_success
    assert_equal({ :controller => 'global', :action => 'show' }, routing_args)

    get '/global/export'
    assert_success
    assert_equal({ :controller => 'global', :action => 'export' }, routing_args)

    get '/global/hide_notice'
    assert_success
    assert_equal({ :controller => 'global', :action => 'hide_notice' }, routing_args)

    get '/export/1/foo'
    assert_success
    assert_equal({ :controller => 'global', :action => 'export', :id => '1', :file => 'foo' }, routing_args)
  end

  def test_optional_route
    get '/optional/index'
    assert_success
    assert_equal({ :controller => 'optional', :action => 'index' }, routing_args)

    get '/optional/index.xml'
    assert_success
    assert_equal({ :controller => 'optional', :action => 'index', :format => 'xml' }, routing_args)
  end

  def test_namespaced_resources
    get '/account/subscription'
    assert_success
    assert_equal({ :controller => 'account/subscription', :action => 'index' }, routing_args)

    get '/account/credit'
    assert_success
    assert_equal({ :controller => 'account/credit', :action => 'index' }, routing_args)
  end

  def test_nested_route
    get '/admin/users'
    assert_success
    assert_equal({ :controller => 'admin/users' }, routing_args)

    get '/admin/groups'
    assert_success
    assert_equal({ :controller => 'admin/groups' }, routing_args)
  end

  def test_regexp
    get '/regexp/foo/bar/123'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'bar', :id => '123' }, routing_args)

    get '/regexp/foos/baz/123'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'baz', :id => '123' }, routing_args)

    get '/regexp/bar/abc/123'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'abc', :id => '123' }, routing_args)

    get '/regexp/baz/abc/123'
    assert_success
    assert_equal({ :controller => 'foo' }, routing_args)

    get '/regexp/bars/foo/baz'
    assert_not_found
  end

  def test_unnamed_capture
    get '/death/star'
    assert_success
    assert_equal({ :controller => 'star' }, routing_args)

    get '/new/death/star'
    assert_success
    assert_equal({ :controller => 'star' }, routing_args)

    get '/death.wsdl/star'
    assert_success
    assert_equal({ :controller => 'star' }, routing_args)
  end

  def test_method_regexp
    get '/method'
    assert_success
    assert_equal({ :controller => 'method', :action => 'index' }, routing_args)

    post '/method'
    assert_success
    assert_equal({ :controller => 'method', :action => 'index' }, routing_args)

    put '/method'
    assert_not_found
  end

  def test_default_route_extracts_parameters
    get '/default/foo/bar/1.xml'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'bar', :id => '1', :format => 'xml' }, routing_args)

    get '/default/foo/bar/1'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'bar', :id => '1' }, routing_args)

    get '/default/foo/bar'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'bar' }, routing_args)

    get '/default/foo'
    assert_success
    assert_equal({ :controller => 'foo' }, routing_args)
  end

  def test_params_override_defaults
    get '/params_with_defaults/bar'
    assert_success
    assert_equal({ :params_with_defaults => true, :controller => 'bar' }, routing_args)

    get '/params_with_defaults'
    assert_success
    assert_equal({ :params_with_defaults => true, :controller => 'foo' }, routing_args)
  end

  def test_escaped_optional_capture
    get '/escaped/(foo)'
    assert_success
    assert_equal({ :controller => 'escaped/foo' }, routing_args)
  end

  def test_path_prefix
    get '/prefix/foo/bar/1'
    assert_success
    assert_equal({ :controller => 'foo', :action => 'bar', :id => '1' }, routing_args)
    assert_equal '/foo/bar/1', @env['PATH_INFO']
    assert_equal '/prefix', @env['SCRIPT_NAME']
  end

  def test_case_insensitive_path
    get '/ignorecase/foo'
    assert_success
    assert_equal({ :controller => 'ignorecase' }, routing_args)

    get '/ignorecase/FOO'
    assert_success
    assert_equal({ :controller => 'ignorecase' }, routing_args)

    get '/ignorecase/Foo'
    assert_success
    assert_equal({ :controller => 'ignorecase' }, routing_args)
  end

  def test_extended_path
    get '/extended/foo'
    assert_success
    assert_equal({ :controller => 'extended' }, routing_args)
  end

  def test_uri_escaping
    get '/uri_escaping/foo'
    assert_success
    assert_equal({ :controller => 'uri_escaping', :value => 'foo' }, routing_args)

    get '/uri_escaping/foo%20bar'
    assert_success
    assert_equal({ :controller => 'uri_escaping', :value => 'foo bar' }, routing_args)

    get '/uri_escaping/%E2%88%9E'
    assert_success
    assert_equal({ :controller => 'uri_escaping', :value => '∞' }, routing_args)
  end

  def test_small_set_with_ambiguous_splitting
    @app = Rack::Mount::RouteSet.new do |set|
      set.add_route(EchoApp, :path_info => Rack::Mount::Strexp.compile('/messages(.:format)'))
      set.add_route(EchoApp, :path_info => Rack::Mount::Strexp.compile('/messages/:id(.:format)'))
      set.add_route(EchoApp, :path_info => Rack::Mount::Strexp.compile('/posts(.:format)'))
      set.add_route(EchoApp, :path_info => Rack::Mount::Strexp.compile('/posts/:id(.:format)'))
    end

    get '/messages'
    assert_success

    get '/messages.xml'
    assert_success

    get '/messages/1'
    assert_success

    get '/messages/1.xml'
    assert_success

    get '/posts'
    assert_success

    get '/posts.xml'
    assert_success
  end
end

class TestOptimizedRecognition < TestRecognition
  def setup
    @app = OptimizedBasicSet
    assert set_included_modules.include?(Rack::Mount::Recognition::CodeGeneration)
  end
end

class TestLinearRecognition < TestRecognition
  def setup
    @app = LinearBasicSet
  end
end
