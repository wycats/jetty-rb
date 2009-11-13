begin
  require 'mg'
  MG.new('rack-mount.gemspec')
rescue LoadError
end


begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end

Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Rack::Mount'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '--charset' << 'utf-8'

  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.exclude('lib/rack/mount/mappers/*.rb')
}

namespace :rdoc do
  task :publish => :rdoc do
    Dir.chdir(File.join(File.dirname(__FILE__), 'doc')) do
      system 'git init'
      system 'git add .'
      system 'git commit -m "generate rdoc"'
      system 'git remote add origin git@github.com:josh/rack-mount.git'
      system 'git checkout -b gh-pages'
      system 'git push -f origin gh-pages'
    end
  end
end


require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  # t.warning = true
end


namespace :vendor do
  task :update_multimap do
    system 'git clone git://github.com/josh/multimap.git'
    FileUtils.cp_r('multimap/lib', 'lib/rack/mount/vendor/multimap')
    FileUtils.rm_rf('multimap')
  end
end
