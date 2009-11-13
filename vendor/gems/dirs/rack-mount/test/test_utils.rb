require 'abstract_unit'

class TestUtils < Test::Unit::TestCase
  include Rack::Mount::Utils

  def test_normalize_path
    assert_equal '/foo', normalize_path('/foo')
    assert_equal '/foo', normalize_path('/foo/')
    assert_equal '/foo', normalize_path('foo')
    assert_equal '/', normalize_path('')
  end

  def test_pop_trailing_nils
    assert_equal [1, 2, 3], pop_trailing_nils!([1, 2, 3])
    assert_equal [1, 2, 3], pop_trailing_nils!([1, 2, 3, nil, nil])
    assert_equal [], pop_trailing_nils!([nil])
  end

  def test_build_nested_query
    assert_equal 'foo', build_nested_query('foo' => nil)
    assert_equal 'foo=', build_nested_query('foo' => '')
    assert_equal 'foo=bar', build_nested_query('foo' => 'bar')
    assert_equal 'foo=1&bar=2', build_nested_query('foo' => '1', 'bar' => '2')
    assert_equal 'my+weird+field=q1%212%22%27w%245%267%2Fz8%29%3F',
      build_nested_query('my weird field' => 'q1!2"\'w$5&7/z8)?')
    assert_equal 'foo%5B%5D', build_nested_query('foo' => [nil])
    assert_equal 'foo%5B%5D=', build_nested_query('foo' => [''])
    assert_equal 'foo%5B%5D=bar', build_nested_query('foo' => ['bar'])
  end

  def test_normalize_extended_expression
    assert_equal %r{foo}, normalize_extended_expression(/foo/)
    assert_equal %r{^/extended/foo$}, normalize_extended_expression(/^\/extended\/ # comment
                                                      foo # bar
                                                      $/x)
  end

  def test_regexp_anchored
    assert_equal true, regexp_anchored?(/^foo$/)
    assert_equal true, regexp_anchored?(/\Afoo\Z/)
    assert_equal false, regexp_anchored?(/foo/)
    assert_equal false, regexp_anchored?(/^foo/)
    assert_equal false, regexp_anchored?(/\Afoo/)
    assert_equal false, regexp_anchored?(/foo$/)
    assert_equal false, regexp_anchored?(/foo\Z/)
  end

  def test_extract_static_regexp
    assert_equal 'foo', extract_static_regexp(/^foo$/)
    assert_equal %r{^foo$}i, extract_static_regexp(/^foo$/i)
    assert_equal 'foo.bar', extract_static_regexp(/^foo\.bar$/)
    assert_equal %r{^foo|bar$}, extract_static_regexp(/^foo|bar$/)
    assert_equal Regexp.union(/^foo$/, /^bar$/),
      extract_static_regexp(Regexp.union(/^foo$/, /^bar$/))
  end

  if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
    def test_extract_named_captures
      assert_equal [/[a-z]+/, []], extract_named_captures(eval('/[a-z]+/'))
      assert_equal [/([a-z]+)/, ['foo']], extract_named_captures(eval('/(?<foo>[a-z]+)/'))
      assert_equal [/([a-z]+)([a-z]+)/, [nil, 'foo']], extract_named_captures(eval('/([a-z]+)(?<foo>[a-z]+)/'))
    end
  else
    def test_extract_named_captures
      assert_equal [/[a-z]+/, []], extract_named_captures(/[a-z]+/)
      assert_equal [/([a-z]+)/, ['foo']], extract_named_captures(/(?:<foo>[a-z]+)/)
      assert_equal [/([a-z]+)([a-z]+)/, [nil, 'foo']], extract_named_captures(/([a-z]+)(?:<foo>[a-z]+)/)
    end
  end
end
