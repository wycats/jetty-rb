require 'abstract_unit'

class TestStrexp < Test::Unit::TestCase
  Strexp = Rack::Mount::Strexp

  def test_leaves_regexps_alone
    assert_equal %r{foo}, Strexp.compile(%r{foo})
  end

  def test_does_mutate_args
    str = 'foo/:bar'.freeze
    requirements = { :bar  => /[a-z]+/.freeze }.freeze
    separators = ['/'.freeze].freeze

    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      assert_equal eval('%r{\Afoo/(?<bar>[a-z]+)\Z}'), Strexp.compile(str, requirements, separators)
    else
      assert_equal %r{\Afoo/(?:<bar>[a-z]+)\Z}, Strexp.compile(str, requirements, separators)
    end
  end

  def test_static_string
    assert_equal %r{\Afoo\Z}, Strexp.compile('foo')
  end

  def test_dynamic_segment
    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      assert_equal eval('%r{\A(?<foo>.+)\.example\.com\Z}'), Strexp.compile(':foo.example.com')
    else
      assert_equal %r{\A(?:<foo>.+)\.example\.com\Z}, Strexp.compile(':foo.example.com')
    end
  end

  def test_dynamic_segment_with_leading_underscore
    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      assert_equal eval('%r{\A(?<_foo>.+)\.example\.com\Z}'), Strexp.compile(':_foo.example.com')
    else
      assert_equal %r{\A(?:<_foo>.+)\.example\.com\Z}, Strexp.compile(':_foo.example.com')
    end
  end

  def test_skips_invalid_group_names
    assert_equal %r{\A:123\.example\.com\Z}, Strexp.compile(':123.example.com')
    assert_equal %r{\A:\$\.example\.com\Z}, Strexp.compile(':$.example.com')
  end

  def test_escaped_dynamic_segment
    assert_equal %r{\A:foo\.example\.com\Z}, Strexp.compile('\:foo.example.com')
  end

  def test_dynamic_segment_with_separators
    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      assert_equal eval('%r{\Afoo/(?<bar>[^/]+)\Z}'), Strexp.compile('foo/:bar', {}, ['/'])
    else
      assert_equal %r{\Afoo/(?:<bar>[^/]+)\Z}, Strexp.compile('foo/:bar', {}, ['/'])
    end
  end

  def test_dynamic_segment_with_requirements
    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      assert_equal eval('%r{\Afoo/(?<bar>[a-z]+)\Z}'), Strexp.compile('foo/:bar', {:bar => /[a-z]+/}, ['/'])
    else
      assert_equal %r{\Afoo/(?:<bar>[a-z]+)\Z}, Strexp.compile('foo/:bar', {:bar => /[a-z]+/}, ['/'])
    end
  end

  def test_dynamic_segment_with_requirements_with_case_insensitive
    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      bar = /bar/i
      assert_equal eval('%r{\Afoo/(?<bar>#{bar})\Z}'), Strexp.compile('foo/:bar', {:bar => /bar/i})
    else
      bar = /bar/i
      assert_equal %r{\Afoo/(?:<bar>#{bar})\Z}, Strexp.compile('foo/:bar', {:bar => /bar/i})
    end
  end

  def test_dynamic_segment_inside_optional_segment
    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      assert_equal eval('%r{\Afoo(\.(?<extension>.+))?\Z}'), Strexp.compile('foo(.:extension)')
    else
      # assert_equal %r{\Afoo(?:\.(?:<extension>.+))?\Z}, Strexp.compile('foo(.:extension)')
      assert_equal %r{\Afoo(\.(?:<extension>.+))?\Z}, Strexp.compile('foo(.:extension)')
    end
  end

  def test_glob_segment
    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      assert_equal eval('%r{\Asrc/(?<files>.+)\Z}'), Strexp.compile('src/*files')
    else
      assert_equal %r{\Asrc/(?:<files>.+)\Z}, Strexp.compile('src/*files')
    end
  end

  def test_glob_segment_at_the_beginning
    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      assert_equal eval('%r{\A(?<files>.+)/foo\.txt\Z}'), Strexp.compile('*files/foo.txt')
    else
      assert_equal %r{\A(?:<files>.+)/foo\.txt\Z}, Strexp.compile('*files/foo.txt')
    end
  end

  def test_glob_segment_in_the_middle
    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      assert_equal eval('%r{\Asrc/(?<files>.+)/foo\.txt\Z}'), Strexp.compile('src/*files/foo.txt')
    else
      assert_equal %r{\Asrc/(?:<files>.+)/foo\.txt\Z}, Strexp.compile('src/*files/foo.txt')
    end
  end

  def test_multiple_glob_segments
    if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
      assert_equal eval('%r{\Asrc/(?<files>.+)/dir/(?<morefiles>.+)/foo\.txt\Z}'), Strexp.compile('src/*files/dir/*morefiles/foo.txt')
    else
      assert_equal %r{\Asrc/(?:<files>.+)/dir/(?:<morefiles>.+)/foo\.txt\Z}, Strexp.compile('src/*files/dir/*morefiles/foo.txt')
    end
  end

  def test_escaped_glob_segment
    assert_equal %r{\Asrc/\*files\Z}, Strexp.compile('src/\*files')
  end

  def test_optional_segment
    # assert_equal %r{\A/foo(?:/bar)?\Z}, Strexp.compile('/foo(/bar)')
    assert_equal %r{\A/foo(/bar)?\Z}, Strexp.compile('/foo(/bar)')
  end

  def test_consecutive_optional_segments
    # assert_equal %r{\A/foo(?:/bar)?(?:/baz)?\Z}, Strexp.compile('/foo(/bar)(/baz)')
    assert_equal %r{\A/foo(/bar)?(/baz)?\Z}, Strexp.compile('/foo(/bar)(/baz)')
  end

  def test_multiple_optional_segments
    # assert_equal %r{\A(?:/foo)?(?:/bar)?(?:/baz)?\Z}, Strexp.compile('(/foo)(/bar)(/baz)')
    assert_equal %r{\A(/foo)?(/bar)?(/baz)?\Z}, Strexp.compile('(/foo)(/bar)(/baz)')
  end

  def test_escapes_optional_segment_parenthesis
    assert_equal %r{\A/foo\(/bar\)\Z}, Strexp.compile('/foo\(/bar\)')
  end

  def test_escapes_one_optional_segment_parenthesis
    # assert_equal %r{\A/foo\((?:/bar)?\Z}, Strexp.compile('/foo\((/bar)')
    assert_equal %r{\A/foo\((/bar)?\Z}, Strexp.compile('/foo\((/bar)')
  end

  def test_raises_regexp_error_if_optional_segment_parenthesises_are_unblanced
    assert_raise(RegexpError) { Strexp.compile('/foo((/bar)') }
    assert_raise(RegexpError) { Strexp.compile('/foo(/bar))') }
  end
end
