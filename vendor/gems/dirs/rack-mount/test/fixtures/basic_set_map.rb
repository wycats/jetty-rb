file = File.join(File.dirname(__FILE__), 'basic_set_map_19.rb')

if Rack::Mount::Const::SUPPORTS_NAMED_CAPTURES
  load(file)
else
  src = File.read(file)
  src.gsub!(/\?<([^>]+)>/, '?:<\1>')
  eval(src)
end
