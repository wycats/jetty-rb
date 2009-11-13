require 'abstract_unit'

class TestMetaMethod < Test::Unit::TestCase
  MetaMethod = Rack::Mount::MetaMethod
  Block = Rack::Mount::MetaMethod::Block
  Condition = Rack::Mount::MetaMethod::Condition

  def test_empty_method
    m = MetaMethod.new(:foo)
    assert_equal "def foo\nend", m.to_str
    assert_equal "def foo\nend\n", m.inspect
  end

  def test_method_with_args
    m = MetaMethod.new(:foo, :bar)
    assert_equal "def foo(bar)\nend", m.to_str
    assert_equal "def foo(bar)\nend\n", m.inspect
  end

  def test_method_with_Block
    m = MetaMethod.new(:foo)
    m << 'return true'
    assert_equal "def foo\nreturn true\nend", m.to_str
    assert_equal "def foo\n  return true\nend\n", m.inspect
  end

  def test_method_with_multiline_Block
    m = MetaMethod.new(:foo)
    m << '1 + 1'
    m << 'return true'
    assert_equal "def foo\n1 + 1; return true\nend", m.to_str
    assert_equal "def foo\n  1 + 1\n  return true\nend\n", m.inspect
  end

  def test_method_with_condition
    m = MetaMethod.new(:foo)
    c = Condition.new
    c << Block.new('true')
    c.body = Block.new('foo', 'bar')
    m << c
    m << 'false'
    assert_equal "def foo\nif true; foo; bar; end; false\nend", m.to_str
    assert_equal "def foo\n  if true\n    foo\n    bar\n  end\n  false\nend\n", m.inspect
  end
end

class TestMetaMethodBlock < Test::Unit::TestCase
  Block = Rack::Mount::MetaMethod::Block

  def test_empty_Block
    b = Block.new
    assert_equal '', b.to_str
    assert_equal '', b.inspect
  end

  def test_single_line
    b = Block.new('return true')
    assert_equal 'return true', b.to_str
    assert_equal '  return true', b.inspect
  end

  def test_multiline
    b = Block.new('1 + 1', 'return true')
    assert_equal '1 + 1; return true', b.to_str
    assert_equal "  1 + 1\n  return true", b.inspect
  end

  def test_create_block_with_block
    b = Block.new do |block|
      block << 'foo = 1'
      block << 'bar = 2'
      block << 'foo + bar'
    end
    assert_equal 'foo = 1; bar = 2; foo + bar', b.to_str
    assert_equal "  foo = 1\n  bar = 2\n  foo + bar", b.inspect
  end
end

class TestMetaMethodCondition < Test::Unit::TestCase
  Block = Rack::Mount::MetaMethod::Block
  Condition = Rack::Mount::MetaMethod::Condition

  def test_single_condition
    c = Condition.new
    c << Block.new('true')
    assert_equal "if true; end", c.to_str
    assert_equal "if true\n  end", c.inspect
  end

  def test_condition_with_body
    c = Condition.new
    c << Block.new('true')
    c.body = Block.new('foo', 'bar')
    assert_equal "if true; foo; bar; end", c.to_str
    assert_equal "if true\n    foo\n    bar\n  end", c.inspect
  end

  def test_condition_with_body_block
    c = Condition.new('true') do |body|
      body << 'foo'
      body << 'bar'
    end
    assert_equal "if true; foo; bar; end", c.to_str
    assert_equal "if true\n    foo\n    bar\n  end", c.inspect
  end

  def test_condition_with_else_body
    c = Condition.new('true') do |body|
      body << 'foo'
      body << 'bar'
    end
    c.else = Block.new('baz')
    assert_equal "if true; foo; bar; else; baz; end", c.to_str
    assert_equal "if true\n    foo\n    bar\n  else\n    baz\n  end", c.inspect
  end

  def test_multiple_conditions
    c = Condition.new
    c << Block.new('true')
    c << Block.new('false')
    assert_equal "if true && false; end", c.to_str
    assert_equal "if true && false\n  end", c.inspect
  end

  def test_single_multiline_condition
    c = Condition.new
    c << Block.new('foo = true', 'foo')
    assert_equal "if (foo = true; foo); end", c.to_str
    assert_equal "if begin\n      foo = true\n      foo\n    end\n  end", c.inspect
  end

  def test_multiple_multiline_condition
    c = Condition.new
    c << Block.new('foo = true', 'foo')
    c << Block.new('bar = false', 'bar')
    assert_equal "if (foo = true; foo) && (bar = false; bar); end", c.to_str
    assert_equal "if begin\n      foo = true\n      foo\n    end && begin\n      bar = false\n      bar\n    end\n  end", c.inspect
  end
end
