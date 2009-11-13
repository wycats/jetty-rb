require 'abstract_unit'

class TestPrefix < Test::Unit::TestCase
  Prefix = Rack::Mount::Prefix

  def test_root
    @app = Prefix.new(EchoApp)

    get '/'
    assert_success
    assert_equal '/', env['PATH_INFO']
    assert_equal '', env['SCRIPT_NAME']
  end

  def test_no_path_prefix_shifting
    @app = Prefix.new(EchoApp)

    get '/foo/bar'
    assert_success
    assert_equal '/foo/bar', env['PATH_INFO']
    assert_equal '', env['SCRIPT_NAME']
  end

  def test_path_prefix_shifting
    @app = Prefix.new(EchoApp, '/foo')

    get '/foo/bar'
    assert_success
    assert_equal '/bar', env['PATH_INFO']
    assert_equal '/foo', env['SCRIPT_NAME']
  end

  def test_path_prefix_shifting_with_env_key
    @app = Prefix.new(EchoApp, '/foo')

    get '/foo2/bar', 'rack.mount.prefix' => '/foo2'
    assert_success
    assert_equal '/bar', env['PATH_INFO']
    assert_equal '/foo2', env['SCRIPT_NAME']
  end

  def test_path_prefix_restores_original_path_when_it_leaves_the_scope
    @app = Prefix.new(EchoApp, '/foo')
    env = {'PATH_INFO' => '/foo/bar', 'SCRIPT_NAME' => ''}
    @app.call(env)
    assert_equal({'PATH_INFO' => '/foo/bar', 'SCRIPT_NAME' => ''}, env)
  end

  def test_path_prefix_shifting_normalizes_path
    @app = Prefix.new(EchoApp, '/foo')

    get '/foo/bar/'
    assert_success
    assert_equal '/bar', env['PATH_INFO']
    assert_equal '/foo', env['SCRIPT_NAME']
  end

  def test_path_prefix_shifting_with_root
    @app = Prefix.new(EchoApp, '/foo')

    get '/foo'
    assert_success
    assert_equal '', env['PATH_INFO']
    assert_equal '/foo', env['SCRIPT_NAME']
  end
end
