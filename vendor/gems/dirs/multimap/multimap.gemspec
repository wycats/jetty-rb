Gem::Specification.new do |s|
  s.name     = 'multimap'
  s.version  = '1.0.1'
  s.date     = '2009-11-07'
  s.summary  = 'Ruby implementation of multimap'
  s.description = <<-EOS
    Multimap includes a Ruby multimap implementation
  EOS
  s.email    = 'josh@joshpeek.com'
  s.homepage = 'http://github.com/josh/multimap'
  s.rubyforge_project = 'multimap'
  s.has_rdoc = true
  s.authors  = ["Joshua Peek"]
  s.files    = [
    "lib/multimap.rb",
    "lib/multiset.rb",
    "lib/nested_multimap.rb"
  ]
  s.extra_rdoc_files = %w[README.rdoc MIT-LICENSE]
end
