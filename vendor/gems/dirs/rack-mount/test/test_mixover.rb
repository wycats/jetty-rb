require 'abstract_unit'

class TestMixover < Test::Unit::TestCase
  Calls = []

  module Bar
    def initialize
      TestMixover::Calls << "Bar#initialize"
      super
    end

    def call
      TestMixover::Calls << "Bar#call"
      super
    end
  end

  class Foo
    extend Rack::Mount::Mixover
    include Bar

    def initialize
      TestMixover::Calls << "Foo#initialize"
    end

    def call
      TestMixover::Calls << "Foo#call"
    end
  end

  def test_module_is_included_on_top_of_base_methods
    foo = Foo.new
    assert_equal ['Bar#initialize', 'Foo#initialize'], TestMixover::Calls

    TestMixover::Calls.clear

    foo.call
    assert_equal ['Bar#call', 'Foo#call'], TestMixover::Calls
  end
end
