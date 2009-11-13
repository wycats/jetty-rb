require 'abstract_unit'

class TestMultimap < Test::Unit::TestCase
  def test_one_level
    set['/people'] = '/people'
    set['/people'] = '/people/1'
    set['/people'] = '/people/new'
    set['/companies'] = '/companies'

    assert_equal ['/people', '/people/1', '/people/new'], set['/people']
    assert_equal ['/companies'], set['/companies']
    assert_equal [], set['/notfound']

    assert_equal 3, set.containers_with_default.length
    assert_equal 3, set.height
  end

  def test_one_level_with_defaults
    set['/people'] = '/people'
    set['/people'] = '/people/1'
    set[/.+/] = '/:controller/edit'
    set['/people'] = '/people/new'
    set['/companies'] = '/companies'
    set[/.+/] = '/:controller/:action'

    assert_equal ['/people', '/people/1', '/:controller/edit', '/people/new', '/:controller/:action'], set['/people']
    assert_equal ['/:controller/edit', '/companies', '/:controller/:action'], set['/companies']
    assert_equal ['/:controller/edit', '/:controller/:action'], set['/notfound']

    assert_equal 3, set.containers_with_default.length
    assert_equal 5, set.height
  end

  def test_regexp
    set['/abc'] = '/abc'
    set['/abc'] = '/abc/show'
    set['/123'] = '/123'
    set['/456'] = '/456'
    set[/\d{3}/] = '/:id'
    set[/.+/] = '/:action'

    assert_equal ['/abc', '/abc/show', '/:action'], set['/abc']
    assert_equal ['/123', '/:id', '/:action'], set['/123']
    assert_equal ['/456', '/:id', '/:action'], set['/456']
    assert_equal ['/:id', '/:action'], set['/789']
    assert_equal ['/:id', '/:action'], set['/notfound']

    assert_equal 4, set.containers_with_default.length
    assert_equal 3, set.height
  end

  def test_nested_buckets
    set['/admin', '/people'] = '/admin/people'
    set['/admin', '/people'] = '/admin/people/1'
    set['/admin', '/people'] = '/admin/people/new'
    set['/admin', '/companies'] = '/admin/companies'

    assert_equal ['/admin/people', '/admin/people/1', '/admin/people/new'], set['/admin', '/people', '/notfound']
    assert_equal ['/admin/people', '/admin/people/1', '/admin/people/new'], set['/admin', '/people']
    assert_equal ['/admin/companies'], set['/admin', '/companies']
    assert_equal [], set['/admin', '/notfound']
    assert_equal [], set['/notfound']

    assert_equal 4, set.containers_with_default.length
    assert_equal 3, set.height
  end

  def test_nested_buckets_with_defaults
    set['/admin'] = '/admin/accounts/new'
    set['/admin', '/people'] = '/admin/people'
    set['/admin', '/people'] = '/admin/people/1'
    set['/admin'] = '/admin/:controller/edit'
    set['/admin', '/people'] = '/admin/people/new'
    set['/admin', '/companies'] = '/admin/companies'
    set[/.+/, '/companies'] = '/:namespace/companies'
    set[/.+/] = '/:controller/:action'

    assert_equal ['/admin/accounts/new', '/admin/people', '/admin/people/1', '/admin/:controller/edit', '/admin/people/new', '/:controller/:action'], set['/admin', '/people']
    assert_equal ['/admin/accounts/new', '/admin/:controller/edit', '/admin/companies', '/:namespace/companies', '/:controller/:action'], set['/admin', '/companies']
    assert_equal ['/admin/accounts/new', '/admin/:controller/edit', '/:controller/:action'], set['/admin', '/notfound']
    assert_equal ['/:controller/:action'], set['/notfound']

    assert_equal 5, set.containers_with_default.length
    assert_equal 6, set.height
  end

  def test_another_nested_buckets_with_defaults
    set['DELETE'] = 'DELETE .*'
    set[/.+/, '/people'] = 'ANY /people/new'
    set['GET', '/people'] = 'GET /people'
    set[/.+/, '/people'] = 'ANY /people/export'
    set['GET', '/people'] = 'GET /people/1'
    set['POST', '/messages'] = 'POST /messages'
    set[/.+/, '/messages'] = 'ANY /messages/export'

    assert_equal ['ANY /people/new', 'GET /people', 'ANY /people/export', 'GET /people/1'], set['GET', '/people']
    assert_equal ['ANY /people/new', 'ANY /people/export'], set['POST', '/people']
    assert_equal ['ANY /people/new', 'ANY /people/export'], set['PUT', '/people']
    assert_equal ['ANY /messages/export'], set['GET', '/messages']
    assert_equal ['POST /messages', 'ANY /messages/export'], set['POST', '/messages']

    assert_equal 12, set.containers_with_default.length
    assert_equal 4, set.height
  end

  def test_nested_with_regexp
    set['GET', 'people'] = 'GET /people'
    set['POST', 'people'] = 'POST /people'
    set['GET', 'people', 'new'] = 'GET /people/new'
    set['GET', 'people', /\d+/] = 'GET /people/:id'
    set['GET', 'people', /\d+/, 'edit'] = 'GET /people/:id/edit'
    set['POST', 'people', /\d+/] = 'POST /people/:id'
    set['PUT', 'people', /\d+/] = 'PUT /people/:id'
    set['DELETE', 'people', /\d+/] = 'DELETE /people/:id'

    assert_equal ['GET /people', 'GET /people/:id'], set['GET', 'people']
    assert_equal ['GET /people', 'GET /people/new'], set['GET', 'people', 'new']
    assert_equal ['GET /people', 'GET /people/:id'], set['GET', 'people', '1']
    assert_equal ['GET /people', 'GET /people/:id', 'GET /people/:id/edit'], set['GET', 'people', '1', 'edit']

    assert_equal 11, set.containers_with_default.length
    assert_equal 3, set.height
  end

  def test_nested_default_bucket
    set[/.+/, '/people'] = 'GET /people'
    set[/.+/, '/people'] = 'GET /people/1'
    set[/.+/, '/messages'] = 'POST /messages'
    set[/.+/] = 'ANY /:controller/:action'

    assert_equal 3, set.containers_with_default.length
    assert_equal 3, set.height
  end

  private
    def set
      @set ||= Rack::Mount::Multimap.new
    end
end
