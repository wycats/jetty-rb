require 'rack/mount/prefix'

module Rack::Mount
  module Recognition
    module Route #:nodoc:
      attr_reader :named_captures

      def initialize(*args)
        super

        # TODO: Don't explict check for :path_info condition
        if @conditions.has_key?(:path_info) &&
            !Utils.regexp_anchored?(@conditions[:path_info])
          @app = Prefix.new(@app)
        end

        @named_captures = {}
        @conditions.map { |method, condition|
          @named_captures[method] = condition.named_captures.inject({}) { |named_captures, (k, v)|
            named_captures[k.to_sym] = v.last - 1
            named_captures
          }.freeze
        }
        @named_captures.freeze
      end

      def call(req)
        env = req.env

        routing_args = @defaults.dup
        if @conditions.all? { |method, condition|
          value = req.send(method)
          if m = value.match(condition)
            matches = m.captures
            @named_captures[method].each { |k, i|
              if v = matches[i]
                # TODO: We only want to unescape params from
                # uri related methods
                routing_args[k] = URI.unescape(v)
              end
            }
            # TODO: Don't explict check for :path_info condition
            if method == :path_info && !Utils.regexp_anchored?(condition)
              env[Prefix::KEY] = m.to_s
            end
            true
          else
            false
          end
        }
          env[@set.parameters_key] = routing_args
          @app.call(env)
        else
          Const::EXPECTATION_FAILED_RESPONSE
        end
      end
    end
  end
end
