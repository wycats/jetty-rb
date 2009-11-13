Gem::Specification.new do |s|
  s.name     = 'rack-mount'
  s.version  = '0.0.1'
  s.date     = '2009-07-12'
  s.summary  = 'Stackable dynamic tree based Rack router'
  s.description = s.summary
  s.email    = 'josh@joshpeek.com'
  s.homepage = 'http://github.com/josh/rack-mount'
  s.has_rdoc = true
  s.authors  = ["Joshua Peek"]
  s.files    = [
    "lib/rack/mount/analysis/frequency.rb",
    "lib/rack/mount/analysis/histogram.rb",
    "lib/rack/mount/analysis/splitting.rb",
    "lib/rack/mount/const.rb",
    "lib/rack/mount/exceptions.rb",
    "lib/rack/mount/generatable_regexp.rb",
    "lib/rack/mount/generation/route.rb",
    "lib/rack/mount/generation/route_set.rb",
    "lib/rack/mount/meta_method.rb",
    "lib/rack/mount/mixover.rb",
    "lib/rack/mount/multimap.rb",
    "lib/rack/mount/prefix.rb",
    "lib/rack/mount/recognition/code_generation.rb",
    "lib/rack/mount/recognition/route.rb",
    "lib/rack/mount/recognition/route_set.rb",
    "lib/rack/mount/regexp_with_named_groups.rb",
    "lib/rack/mount/route.rb",
    "lib/rack/mount/route_set.rb",
    "lib/rack/mount/strexp.rb",
    "lib/rack/mount/utils.rb",
    "lib/rack/mount/vendor/multimap/multimap.rb",
    "lib/rack/mount/vendor/multimap/multiset.rb",
    "lib/rack/mount/vendor/multimap/nested_multimap.rb",
    "lib/rack/mount.rb"
  ]
  s.extra_rdoc_files = %w[README.rdoc LICENSE]
  s.require_paths = %w[lib]
  s.add_dependency 'rack', '>= 1.0.0'
  s.add_dependency 'multimap', '>= 1.0.0'
end
