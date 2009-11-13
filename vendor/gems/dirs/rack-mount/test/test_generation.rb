# encoding: utf-8
require 'abstract_unit'

class TestGeneration < Test::Unit::TestCase
  def setup
    @app = BasicSet
    assert !set_included_modules.include?(Rack::Mount::Recognition::CodeGeneration)
  end

  Person = Struct.new(:to_param)

  def test_url_with_named_route
    assert_equal '/login', @app.url(:login)
    assert_equal '/logout', @app.url(:logout)
    assert_equal '/geocode/60622', @app.url(:geocode, :postalcode => '60622')
    assert_equal '/', @app.url(:root)

    assert_equal '/people/1', @app.url(:person, :id => '1')
    assert_equal '/people/1', @app.url(:person, :id => Person.new('1'))
    assert_equal '/people/%231', @app.url(:person, :id => '#1')
    assert_equal '/people/number%20one', @app.url(:person, :id => 'number one')

    assert_equal '/global/export', @app.url(:export_request)
    assert_equal '/global/hide_notice', @app.url(:hide_notice)
    assert_equal '/export/1/file.txt', @app.url(:export_download, :id => '1', :file => 'file.txt')

    assert_equal '/regexp/bar/abc/123', @app.url(:complex_regexp, :action => 'abc', :id => '123')
    assert_equal nil, @app.url(:complex_regexp_fail)

    assert_equal '/prefix', @app.url(:prefix)
  end

  def test_url_with_hash
    assert_equal '/login', @app.url(:controller => 'sessions', :action => 'new')
    assert_equal '/logout', @app.url(:controller => 'sessions', :action => 'destroy')

    assert_equal '/global/show', @app.url(:controller => 'global', :action => 'show')
    assert_equal '/global/export', @app.url(:controller => 'global', :action => 'export')

    assert_equal '/account2', @app.url(:controller => 'account2', :action => 'subscription')
    assert_equal '/account2/billing', @app.url(:controller => 'account2', :action => 'billing')

    assert_equal '/foo', @app.url(:controller => 'foo', :action => 'index')
    assert_equal '/foo/bar', @app.url(:controller => 'foo_bar', :action => 'index')
    assert_equal '/baz', @app.url(:controller => 'baz', :action => 'index')

    assert_equal '/ws/foo', @app.url(:ws => true, :controller => 'foo')
    assert_equal '/ws/foo/list', @app.url(:ws => true, :controller => 'foo', :action => 'list')

    assert_equal '/params_with_defaults', @app.url(:params_with_defaults => true, :controller => 'foo')
    assert_equal '/params_with_defaults/bar', @app.url(:params_with_defaults => true, :controller => 'bar')

    assert_equal '/pages/1/users/show/2', @app.url(:page_id => '1', :controller => 'users', :action => 'show', :id => '2')
    assert_equal '/default/users/show/1', @app.url(:controller => 'users', :action => 'show', :id => '1')
    assert_equal '/default/users/show/1', @app.url({:action => 'show', :id => '1'}, {:controller => 'users'})
    assert_equal '/default/users/show/1', @app.url({:controller => 'users', :id => '1'}, {:action => 'show'})
  end

  def test_generate_host
    assert_equal ['josh.backpackit.com', {}], @app.generate(:host, :controller => 'account', :account => 'josh')
    assert_equal [['josh.backpackit.com', '/host'], {}], @app.generate([:host, :path_info], :controller => 'account', :account => 'josh')
  end

  def test_does_not_mutuate_params
    assert_equal '/login', @app.url({:controller => 'sessions', :action => 'new'}.freeze)
    assert_equal ['josh.backpackit.com', {}], @app.generate(:host, {:controller => 'account', :account => 'josh'}.freeze)
  end

  def test_url_with_query_string
    assert_equal '/login?token=1', @app.url(:login, :token => '1')
    assert_equal '/login?token=1', @app.url(:controller => 'sessions', :action => 'new', :token => '1')
    # Not sure if escaping []s is correct
    assert_equal '/login?token%5B%5D=1&token%5B%5D=2', @app.url(:login, :token => ['1', '2'])
  end

  def test_uses_default_parameters_when_non_are_passed
    assert_equal '/feed/atom', @app.url(:feed, :kind => 'atom')
    assert_equal '/feed/rss', @app.url(:feed, :kind => 'rss')
    assert_equal '/feed/rss', @app.url(:feed)

    assert_equal '/feed2.atom', @app.url(:feed2, :format => 'atom')
    assert_equal '/feed2', @app.url(:feed2, :format => 'rss')
    assert_equal '/feed2', @app.url(:feed2)
  end

  def test_uri_escaping
    assert_equal '/uri_escaping/foo', @app.url(:controller => 'uri_escaping', :value => 'foo')
    assert_equal '/uri_escaping/foo%20bar', @app.url(:controller => 'uri_escaping', :value => 'foo bar')
    # assert_equal '/uri_escaping/foo%20bar', @app.url(:controller => 'uri_escaping', :value => 'foo%20bar')
    assert_equal '/uri_escaping/%E2%88%9E', @app.url(:controller => 'uri_escaping', :value => '∞')
    # assert_equal '/uri_escaping/%E2%88%9E', @app.url(:controller => 'uri_escaping', :value => '%E2%88%9E')
  end
end

class TestOptimizedGeneration < TestGeneration
  def setup
    @app = OptimizedBasicSet
    assert set_included_modules.include?(Rack::Mount::Recognition::CodeGeneration)
  end
end

class TestLinearGeneration < TestGeneration
  def setup
    @app = LinearBasicSet
  end
end
