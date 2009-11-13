require 'abstract_unit'

class TestRouteSet < Test::Unit::TestCase
  def setup
    @app = BasicSet
    assert !set_included_modules.include?(Rack::Mount::Recognition::CodeGeneration)
  end

  def test_rehash_builds_graph
    set = Rack::Mount::RouteSet.new
    assert_raise(RuntimeError) { set.call({}) }
    assert_raise(RuntimeError) { set.url(:foo) }

    set.rehash
    assert_nothing_raised(RuntimeError) { set.call({}) }
    assert_raise(Rack::Mount::RoutingError) { set.url(:foo) }
  end

  def test_ensure_routeset_needs_to_be_frozen
    set = Rack::Mount::RouteSet.new
    assert_raise(RuntimeError) { set.call({}) }
    assert_raise(RuntimeError) { set.url(:foo) }

    set.freeze
    assert_nothing_raised(RuntimeError) { set.call({}) }
    assert_raise(Rack::Mount::RoutingError) { set.url(:foo) }
  end

  def test_ensure_each_route_requires_a_valid_rack_app
    set = Rack::Mount::RouteSet.new
    assert_nothing_raised(ArgumentError) { set.add_route(EchoApp, :path_info => '/foo') }
    assert_raise(ArgumentError) { set.add_route({}) }
    assert_raise(ArgumentError) { set.add_route('invalid app') }
  end

  def test_ensure_route_has_valid_conditions
    set = Rack::Mount::RouteSet.new
    assert_nothing_raised(ArgumentError) { set.add_route(EchoApp, :path_info => '/foo') }
    assert_raise(ArgumentError) { set.add_route(EchoApp, nil) }
    assert_raise(ArgumentError) { set.add_route(EchoApp, :foo => '/bar') }
  end

  def test_dupping
    dupped = @app.dup
    assert_equal((class << @app; included_modules; end),
      (class << dupped; included_modules; end))
  end

  def test_cloning
    cloned = @app.clone
    assert_equal((class << @app; included_modules; end),
      (class << cloned; included_modules; end))
  end

  # def test_marshaling
  #   set = Rack::Mount::RouteSet.new
  #   set.add_route(EchoApp)
  #
  #   data = Marshal.dump(set)
  #   assert_kind_of Rack::Mount::RouteSet, Marshal.load(data)
  # end

  def test_worst_case
    # Make sure we aren't making the tree less efficient. Its okay if
    # this number gets smaller. However it may increase if the more
    # routes are added to the test fixture.
    assert_equal 10, @app.instance_variable_get('@recognition_graph').height
    assert_equal 11, @app.instance_variable_get('@generation_graph').height
  end

  def test_average_case
    # This will probably change wildly, but still an interesting
    # statistic to track
    assert_equal 4, @app.instance_variable_get('@recognition_graph').average_height.to_i
    assert_equal 7, @app.instance_variable_get('@generation_graph').average_height.to_i
  end
end

class TestOptimizedRouteSet < TestRouteSet
  def setup
    @app = OptimizedBasicSet
    assert set_included_modules.include?(Rack::Mount::Recognition::CodeGeneration)
  end
end

class TestLinearRouteSet < TestRouteSet
  def setup
    @app = LinearBasicSet
  end

  def test_worst_case
    assert_equal @app.length, @app.instance_variable_get('@recognition_graph').height
    assert_equal @app.length, @app.instance_variable_get('@generation_graph').height
  end

  def test_average_case
    assert_equal @app.length, @app.instance_variable_get('@recognition_graph').average_height.to_i
    assert_equal @app.length, @app.instance_variable_get('@generation_graph').average_height.to_i
  end
end
