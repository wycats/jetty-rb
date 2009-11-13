require 'helper'

Map = Proc.new {
  ('a'..'zz').each do |path|
    add("/#{path}").to(EchoApp)
  end
}

require 'rack/mount'
Mount = Rack::Mount::UsherMapper.map(&Map) 

require 'usher'
Ush = Usher::Interface.for(:rack, &Map)

TIMES = 10_000.to_i

MountFirstEnv = EnvGenerator.env_for(TIMES, '/a')
UshFirstEnv = EnvGenerator.env_for(TIMES, '/a')

MountMidEnv = EnvGenerator.env_for(TIMES, '/mn')
UshMidEnv = EnvGenerator.env_for(TIMES, '/mn')

MountLastEnv = EnvGenerator.env_for(TIMES, '/zz')
UshLastEnv = EnvGenerator.env_for(TIMES, '/zz')

Benchmark.bmbm do |x|
  x.report('rack-mount (first)')  { TIMES.times { |n| Mount.call(MountFirstEnv[n]) } }
  x.report('usher (first)')       { TIMES.times { |n| Ush.call(UshFirstEnv[n]) } }
  x.report('rack-mount (mid)')    { TIMES.times { |n| Mount.call(MountMidEnv[n]) } }
  x.report('usher (mid)')         { TIMES.times { |n| Ush.call(UshMidEnv[n]) } }
  x.report('rack-mount (last)')   { TIMES.times { |n| Mount.call(MountLastEnv[n]) } }
  x.report('usher (last)')        { TIMES.times { |n| Ush.call(UshLastEnv[n]) } }
end

#                          user     system      total        real
# rack-mount (first)   0.330000   0.000000   0.330000 (  0.325292)
# usher (first)        0.440000   0.000000   0.440000 (  0.436666)
# rack-mount (mid)     0.350000   0.000000   0.350000 (  0.347230)
# usher (mid)          0.380000   0.000000   0.380000 (  0.384767)
# rack-mount (last)    0.360000   0.000000   0.360000 (  0.359773)
# usher (last)         0.440000   0.000000   0.440000 (  0.446505)
