require 'rack/mount/utils'

module Rack::Mount
  class Prefix #:nodoc:
    KEY = 'rack.mount.prefix'.freeze

    def initialize(app, prefix = nil)
      @app, @prefix = app, prefix.freeze
      freeze
    end

    def call(env)
      if prefix = env[KEY] || @prefix
        old_path_info = env[Const::PATH_INFO].dup
        old_script_name = env[Const::SCRIPT_NAME].dup

        begin
          env[Const::PATH_INFO] = Utils.normalize_path(env[Const::PATH_INFO].sub(prefix, Const::EMPTY_STRING))
          env[Const::PATH_INFO] = Const::EMPTY_STRING if env[Const::PATH_INFO] == Const::SLASH
          env[Const::SCRIPT_NAME] = Utils.normalize_path(env[Const::SCRIPT_NAME].to_s + prefix)
          @app.call(env)
        ensure
          env[Const::PATH_INFO] = old_path_info
          env[Const::SCRIPT_NAME] = old_script_name
        end
      else
        @app.call(env)
      end
    end
  end
end
