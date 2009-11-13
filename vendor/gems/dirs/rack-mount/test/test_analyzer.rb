require 'abstract_unit'

class Array
  def all_permutations
    a = []
    (0..size).each { |n| _each_permutation(n) { |e| a << e } }
    a
  end

  def _each_permutation(n)
    if size < n or n < 0
    elsif n == 0
      yield([])
    else
      self[1..-1]._each_permutation(n - 1) do |x|
        (0...n).each do |i|
          yield(x[0...i] + [first] + x[i..-1])
        end
      end
      self[1..-1]._each_permutation(n) do |x|
        yield(x)
      end
    end
  end
  protected :_each_permutation
end

class GraphReport
  def initialize(possible_keys)
    @possible_keys = possible_keys
  end

  def full_report
    @full_report ||= begin
      report = {}
      uniq_keys.all_permutations.each do |permutation|
        graph = graph(permutation)
        report[permutation] = {
          :key_count => permutation.size,
          :graph_height => graph.height,
          :graph_average => graph.average_height
        }
      end
      report
    end
  end

  def filtered_by_max_height
    @filtered_by_max_height ||= filter_minimum_statistic(full_report, :graph_height)
  end

  def filtered_by_avg_height
    @filtered_by_avg_height ||= filter_minimum_statistic(filtered_by_max_height, :graph_average)
  end

  def filtered_by_key_count
    @filtered_by_key_count ||= filter_minimum_statistic(filtered_by_avg_height, :key_count)
  end

  def good_choices
    @good_choices ||= format_report(filtered_by_max_height)
  end

  def better_choices
    @best_choices ||= format_report(filtered_by_avg_height)
  end

  def best_choices
    @best_choices ||= format_report(filtered_by_key_count)
  end

  def message
    <<-EOS
    Graph Report for: #{uniq_keys.join(', ')}
      Best: #{best_choices.map { |e| e.inspect }.join(', ')}
      Better: #{better_choices.map { |e| e.inspect }.join(', ')}
      Good: #{good_choices.map { |e| e.inspect }.join(', ')}
    EOS
  end

  private
    def filter_minimum_statistic(report, stat)
      min = report.inject(1/0.0) { |min, (_, stats)| min > stats[stat] ? stats[stat] : min }
      report.select { |_, stats| stats[stat] == min }
    end

    def format_report(report)
      report.inject([]) { |choices, (keys, _)|
        choices << keys
        choices
      }
    end

    def uniq_keys
      @possible_keys.map { |e| e.keys }.flatten.uniq
    end

    def graph(keys)
      graph = Rack::Mount::Multimap.new
      @possible_keys.each do |possible_key|
        graph_keys = keys.map { |k| possible_key[k] }
        Rack::Mount::Utils.pop_trailing_nils!(graph_keys)
        graph_keys.map! { |k| k || /.+/ }
        graph[*graph_keys] = true
      end
      graph
    end
end

class TestAnalyzer < Test::Unit::TestCase
  def test_reports_are_the_best
    assert_report(:best)

    assert_report(:best,
      {:controller => 'people', :action => 'index'},
      {:controller => 'people', :action => 'show'},
      {:controller => 'posts', :action => 'index'}
    )
  end

  # TODO: Try to improve the analyzer so we can promote these
  # test cases to "best"
  def test_reports_are_better
    assert_report(:better,
      {:foo => 'bar'},
      {:foo => 'bar'}
    )

    assert_report(:better,
      {:foo => 'bar'},
      {:foo => 'bar'},
      {:foo => 'bar'},
      {:foo => 'bar'},
      {:foo => 'bar'}
    )

    assert_report(:better,
      {:controller => 'people'},
      {:controller => 'people', :action => 'show'},
      {:controller => 'posts', :action => 'show'}
    )
  end

  # TODO: Try to improve the analyzer so we can promote these
  # test cases to "better"
  def test_reports_are_good
    assert_report(:good, :foo => 'bar')

    assert_report(:good,
      {:method => 'GET', :path => '/people/1'},
      {:method => 'GET', :path => '/messages/1'},
      {:method => 'POST', :path => '/comments'}
    )

    assert_report(:good,
      {:method => 'GET', :path => '/people'},
      {:method => 'GET', :path => '/posts'},
      {:method => 'GET', :path => '/messages'},
      {:method => 'GET', :path => '/comments'}
    )
  end

  def test_analysis_boundaries
    assert_equal(['/', 's'], Rack::Mount::Analysis::Frequency.new_with_module(Rack::Mount::Analysis::Splitting,
      {:path => %r{^/people/([0-9]+)$}},
      {:path => %r{^/messages(/([0-9]+))$}},
      {:path => %r{^/comments$} }
    ).separators(:path))

    assert_equal(['e', '.'], Rack::Mount::Analysis::Frequency.new_with_module(Rack::Mount::Analysis::Splitting,
      {:path => %r{^/people(\.([a-z]+))?$}}
    ).separators(:path))

    assert_equal(['.'], Rack::Mount::Analysis::Frequency.new_with_module(Rack::Mount::Analysis::Splitting,
      {:host => %r{^([a-z+]).37signals.com$}}
    ).separators(:host))

    assert_equal(['-'], Rack::Mount::Analysis::Frequency.new_with_module(Rack::Mount::Analysis::Splitting,
      {:foo => %r{^foo-([a-z+])-bar$}}
    ).separators(:foo))
  end

  private
    def assert_report(quality, *keys)
      actual = Rack::Mount::Analysis::Frequency.new(*keys).report
      expected = GraphReport.new(keys)
      assert(expected.send("#{quality}_choices").include?(actual), "Analysis report yield #{actual.inspect} but:\n#{expected.message}\n")
    end
end
