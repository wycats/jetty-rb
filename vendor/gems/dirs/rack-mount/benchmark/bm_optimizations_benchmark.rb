require 'helper'
require 'fixtures'

TIMES = 10_000.to_i
Env = EnvGenerator.env_for(TIMES, '/account/credit_card/1')

Benchmark.bmbm do |x|
  x.report('unoptimized') { TIMES.times { |n| BasicSet.call(Env[n]) } }
  x.report('optimized')   { TIMES.times { |n| OptimizedBasicSet.call(Env[n]) } }
end
