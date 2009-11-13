begin
  require 'mg'
  mg = MG.new('multimap.gemspec')
  $spec = mg.spec
rescue LoadError
end


require 'rake/rdoctask'

Rake::RDocTask.new { |rdoc|
  rdoc.title    = 'Multimap'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '--charset' << 'utf-8'

  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

namespace :rdoc do
  task :publish => :rdoc do
    Dir.chdir(File.dirname(__FILE__)) do
      system "scp -r html/* joshpeek@rubyforge.org:/var/www/gforge-projects/multimap/"
    end
  end
end

task :default => :spec

require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.libs << 'lib'
  t.ruby_opts = ['-w']
end


begin
  require 'rake/extensiontask'

  Rake::ExtensionTask.new do |ext|
    ext.name = 'nested_multimap_ext'
    ext.gem_spec = $spec
  end

  desc "Run specs using C ext"
  task "spec:ext" => [:compile, :spec, :clobber]
rescue LoadError
end
