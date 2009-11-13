require 'abstract_unit'

unless Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
  class TestRegexpWithNamedGroups < Test::Unit::TestCase
    RegexpWithNamedGroups = Rack::Mount::RegexpWithNamedGroups

    def test_simple_regexp
      regexp = RegexpWithNamedGroups.new(/foo/)
      assert_equal(/foo/, regexp)
      assert_equal([], regexp.names)
      assert_equal({}, regexp.named_captures)
    end

    def test_regexp_with_captures
      regexp = RegexpWithNamedGroups.new(/(bar|baz)/)
      assert_equal(/(bar|baz)/, regexp)
      assert_equal([], regexp.names)
      assert_equal({}, regexp.named_captures)
    end

    def test_regexp_with_named_captures
      regexp = RegexpWithNamedGroups.new(/(?:<foo>bar|baz)/)
      assert_equal(/(bar|baz)/, regexp)
      assert_equal(['foo'], regexp.names)
      assert_equal({ 'foo' => [1]}, regexp.named_captures)
    end
  end
end
