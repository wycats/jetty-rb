require 'multimap'

require 'spec/enumerable_examples'
require 'spec/hash_examples'

describe Multimap, "with inital values {'a' => [100], 'b' => [200, 300]}" do
  it_should_behave_like "Enumerable Multimap with inital values {'a' => [100], 'b' => [200, 300]}"
  it_should_behave_like "Hash Multimap with inital values {'a' => [100], 'b' => [200, 300]}"

  before do
    @map = Multimap["a" => 100, "b" => [200, 300]]
  end
end

describe Multimap, "with inital values {'a' => [100], 'b' => [200, 300]}" do
  it_should_behave_like "Enumerable Multimap with inital values {'a' => [100], 'b' => [200, 300]}"
  it_should_behave_like "Hash Multimap with inital values {'a' => [100], 'b' => [200, 300]}"

  before do
    @map = Multimap["a", 100, "b", [200, 300]]
  end
end

require 'set'

describe Multimap, "with", Set do
  it_should_behave_like "Enumerable Multimap with inital values {'a' => [100], 'b' => [200, 300]}"
  it_should_behave_like "Hash Multimap with inital values {'a' => [100], 'b' => [200, 300]}"

  before do
    @container = Set
    @map = Multimap.new(@container.new)
    @map["a"] = 100
    @map["b"] = 200
    @map["b"] = 300
  end
end


class MiniArray
  attr_accessor :data

  def initialize(data = [])
    @data = data
  end

  def initialize_copy(orig)
    @data = orig.data.dup
  end

  def <<(value)
    @data << value
  end

  def each(&block)
    @data.each(&block)
  end

  def delete(value)
    @data.delete(value)
  end

  def ==(other)
    other.is_a?(self.class) && @data == other.data
  end

  def eql?(other)
    other.is_a?(self.class) && @data.eql?(other.data)
  end
end

describe Multimap, "with", MiniArray do
  it_should_behave_like "Enumerable Multimap with inital values {'a' => [100], 'b' => [200, 300]}"
  it_should_behave_like "Hash Multimap with inital values {'a' => [100], 'b' => [200, 300]}"

  before do
    @container = MiniArray
    @map = Multimap.new(@container.new)
    @map["a"] = 100
    @map["b"] = 200
    @map["b"] = 300
  end
end
