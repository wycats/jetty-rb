require 'helper'

Map = Proc.new { 
  add('/a/:a/x').to(EchoApp)
  ('a'..'w').each do |path|
    add("/a/:a/#{path}").to(EchoApp)
  end
  add('/a/:a/y').to(EchoApp)
  ('a'..'w').each do |path|
    add("/a/:a/#{path}").to(EchoApp)
  end
  add('/a/:a/z').to(EchoApp)
}

require 'rack/mount'
Mount = Rack::Mount::UsherMapper.map(&Map) 

require 'usher'
Ush = Usher::Interface.for(:rack, &Map)

TIMES = 10_000.to_i

MountFirstEnv = EnvGenerator.env_for(TIMES, '/a/b/x')
UshFirstEnv = EnvGenerator.env_for(TIMES, '/a/b/x')

MountMidEnv = EnvGenerator.env_for(TIMES, '/a/b/y')
UshMidEnv = EnvGenerator.env_for(TIMES, '/a/b/y')

MountLastEnv = EnvGenerator.env_for(TIMES, '/a/b/z')
UshLastEnv = EnvGenerator.env_for(TIMES, '/a/b/z')

Benchmark.bmbm do |x|
  x.report('rack-mount (first)') { TIMES.times { |n| Mount.call(MountFirstEnv[n]) } }
  x.report('usher (first)')      { TIMES.times { |n| Ush.call(UshFirstEnv[n]) } }
  x.report('rack-mount (mid)')   { TIMES.times { |n| Mount.call(MountMidEnv[n]) } }
  x.report('usher (mid)')        { TIMES.times { |n| Ush.call(UshMidEnv[n]) } }
  x.report('rack-mount (last)')  { TIMES.times { |n| Mount.call(MountLastEnv[n]) } }
  x.report('usher (last)')       { TIMES.times { |n| Ush.call(UshLastEnv[n]) } }
end

#                          user     system      total        real
# rack-mount (first)   0.580000   0.010000   0.590000 (  0.661843)
# usher (first)        0.800000   0.020000   0.820000 (  0.870902)
# rack-mount (mid)     0.570000   0.010000   0.580000 (  0.606821)
# usher (mid)          0.880000   0.010000   0.890000 (  0.945685)
# rack-mount (last)    0.570000   0.000000   0.570000 (  0.599304)
# usher (last)         0.880000   0.010000   0.890000 (  0.912738)
