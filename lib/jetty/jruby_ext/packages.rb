require "java"

module Java
  class Packages
    class << self
      @@all_packages = {}

      def all
        @@all_packages
      end

      def add_jar(jar)
        next unless File.exists?(jar)

        entries = java.util.jar.JarFile.new(java.io.File.new(jar)).entries
        entries.each do |x|
          next if x.name !~ /\.class$/ || x.name =~ /\$/
          chunks = x.name.split(%r{[./\$]})[0..-2]
          add_package(chunks)
        end
      end

      def add_package(parts)
        current = @@all_packages
        parts.each do |part|
          current = (current[part] ||= {})
        end
      end

      def children(package)
        package.split(".").inject(@@all_packages) do |package, part|
          package[part]
        end.keys
      end
    end

    java.lang.System.getProperty("sun.boot.class.path").split(":").each {|jar| add_jar(jar) }
  end
end

module JavaPackageModuleTemplate
  class << self
    def included(klass)
      __import_children_into__(klass)
      super
    end
    
    def __import_children_into__(mod)
      children = Java::Packages.children(package_name)
      package = self
      
      mod.module_eval do
        children.each do |child|
          name = child.gsub(/^[a-z]/) {|m| m.upcase }
          const_set name, package.__send__(child)
        end
      end
    end

    def const_missing(const)
      children = Java::Packages.children(package_name)

      if child = children.find {|c| c.gsub(/^[a-z]/) {|m| m.upcase } == const.to_s }
        return __send__(child)
      end
      super
    end
    private :const_missing
  end
end

module Kernel
  def load_jar(path)
    unless path =~ %r{^/}
      $LOAD_PATH.each do |load_path|
        searched = File.expand_path(File.join(load_path, path))
        searched.gsub! /(.jar)?$/, '.jar'
        path = searched if File.exist?(searched)
      end
    end

    Java::Packages.add_jar(path)
    require path
  end

  def using(hash, &block)
    m = Module.new do
      hash.keys.each do |package|
        package.__import_children_into__(self)
      end
    end

    JRuby.reference(block).block.body.static_scope.module = m
    m.module_eval(&block)
  end
end