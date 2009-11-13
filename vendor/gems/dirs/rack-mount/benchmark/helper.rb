require 'rack/mount'
require 'benchmark'

class Rack::Mount::UsherMapper
  def self.map(&block)
    context = new
    context.instance_eval(&block)
    context.freeze
  end

  def initialize
    @set = Rack::Mount::RouteSet.new
    @path_info = nil
  end

  def freeze
    @set.freeze
  end

  def add(path)
    @path_info = Rack::Mount::Strexp.compile(path, {}, ['/'])
    self
  end

  def to(app)
    @set.add_route(app, :path_info => @path_info)
    @path_info = nil
    self
  end
end

module EnvGenerator
  def env_for(n, *args)
    envs = []
    n.times { envs << Rack::MockRequest.env_for(*args) }
    envs
  end
  module_function :env_for
end

EchoApp = lambda { |env| Rack::Mount::Const::OK_RESPONSE }

def Object.const_missing(name)
  if name.to_s =~ /Controller$/
    EchoApp
  else
    super
  end
end

require 'set'

def track_new_objects
  object_ids  = Set.new
  new_objects = Set.new

  ObjectSpace.each_object { |obj| object_ids << obj.object_id }

  yield

  ObjectSpace.each_object { |obj|
    unless object_ids.include?(obj.object_id)
      new_objects << obj
    end
  }

  new_objects
end

def profile_memory_usage
  unless GC.respond_to?(:enable_stats)
    abort 'Use REE so you can profile memory and object allocation'
  end

  GC.enable_stats

  yield # warmup

  GC.start
  before = GC.allocated_size
  before_rss = `ps -o rss= -p #{Process.pid}`.to_i
  before_live_objects = ObjectSpace.live_objects

  elapsed = Benchmark.realtime { yield }

  GC.start
  after_live_objects = ObjectSpace.live_objects
  after_rss = `ps -o rss= -p #{Process.pid}`.to_i
  after = GC.allocated_size
  usage = (after - before) / 1024.0

  puts "%10.2f KB %10d obj %8.1f ms  %d KB RSS" %
    [usage, after_live_objects - before_live_objects, elapsed * 1000, after_rss - before_rss]

  nil
end

begin
  require 'ruby-prof'

  OUTPUT = File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'performance')

  PRINTERS = {
    :flat => RubyProf::FlatPrinter,
    :graph => RubyProf::GraphHtmlPrinter,
    :tree => RubyProf::CallTreePrinter
  }

  PRINTER_OUTPUT = {
    :flat => 'flat.txt',
    :graph => 'graph.html',
    :tree => 'tree.txt'
  }

  MEASUREMENTS = {
    :process_time => RubyProf::PROCESS_TIME,
    :memory => RubyProf::MEMORY,
    :objects => RubyProf::ALLOCATIONS
  }

  def profile(name, measurement, printer, &block)
    FileUtils.mkdir_p(OUTPUT)

    suffix   = PRINTER_OUTPUT[printer]
    filename = "#{OUTPUT}/#{name}_#{measurement}_#{suffix}"

    RubyProf.measure_mode = MEASUREMENTS[measurement]
    printer_klass         = PRINTERS[printer]

    result  = RubyProf.profile(&block)
    printer = printer_klass.new(result)

    File.open(filename, 'wb') do |file|
      printer.print(file, :min_percent => 0.01)
    end
  end

  def profile_all(name, &block)
    PRINTER_OUTPUT.keys.each do |printer|
      MEASUREMENTS.keys.each do |measurement|
        profile(name, measurement, printer, &block)
      end
    end
  end
rescue LoadError
end
