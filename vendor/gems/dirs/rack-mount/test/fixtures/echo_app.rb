require 'yaml'

class EchoApp
  def self.call(env)
    [200, {Rack::Mount::Const::CONTENT_TYPE => 'text/yaml'}, [YAML.dump(env)]]
  end
end
