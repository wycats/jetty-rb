require 'rack/mount/meta_method'

module Rack::Mount
  module Recognition
    module CodeGeneration #:nodoc:
      def _expired_call(env) #:nodoc:
        raise 'route set not finalized'
      end

      def rehash
        super
        optimize_call!
      end

      private
        def expire!
          class << self
            alias_method :call, :_expired_call
          end

          super
        end

        def optimize_container_iterator(container)
          m = MetaMethod.new(:optimized_each, :req)
          m << 'env = req.env'

          container.each_with_index { |route, i|
            path_info_unanchored = route.conditions[:path_info] &&
              !Utils.regexp_anchored?(route.conditions[:path_info])
            m << "route = self[#{i}]"
            m << 'routing_args = route.defaults.dup'

            m << matchers = MetaMethod::Condition.new do |body|
              body << "env[#{@parameters_key.inspect}] = routing_args"
              body << "response = route.app.call(env)"
              body << "return response unless response[0].to_i == 417"
            end

            route.conditions.each do |method, condition|
              matchers << MetaMethod::Block.new do |matcher|
                matcher << c = MetaMethod::Condition.new("m = req.#{method}.match(#{condition.inspect})") do |b|
                  b << "matches = m.captures" if route.named_captures[method].any?
                  route.named_captures[method].each do |k, i|
                    b << MetaMethod::Condition.new("p = matches[#{i}]") do |c2|
                      c2 << "routing_args[#{k.inspect}] = URI.unescape(p)"
                    end
                  end
                  if method == :path_info && !Utils.regexp_anchored?(condition)
                    b << "env[Prefix::KEY] = m.to_s"
                  end
                  b << "true"
                end
                c.else = MetaMethod::Block.new("false")
              end
            end
          }

          m << 'nil'
          # puts "\n#{m.inspect}"
          container.instance_eval(m, __FILE__, __LINE__)
        end

        def optimize_call!
          method = MetaMethod.new(:call, :env)

          if @routes.empty?
            method << 'env[Const::EXPECT] != Const::CONTINUE ? Const::NOT_FOUND_RESPONSE : Const::EXPECTATION_FAILED_RESPONSE'
          else
            method << 'begin'
            method << 'set_expectation = env[Const::EXPECT] != Const::CONTINUE'
            method << 'env[Const::EXPECT] = Const::CONTINUE if set_expectation'

            method << 'env[Const::PATH_INFO] = Utils.normalize_path(env[Const::PATH_INFO])'
            method << "req = #{@request_class.name}.new(env)"
            cache = false
            keys = @recognition_keys.map { |key|
              if key.is_a?(Array)
                cache = true
                key.call_source(:cache, :req)
              else
                "req.#{key}"
              end
            }.join(', ')
            method << 'cache = {}' if cache
            method << "container = @recognition_graph[#{keys}]"
            method << "optimize_container_iterator(container) unless container.respond_to?(:optimized_each)"
            method << "container.optimized_each(req) || (set_expectation ? Const::NOT_FOUND_RESPONSE : Const::EXPECTATION_FAILED_RESPONSE)"
            method << 'ensure'
            method << 'env.delete(Const::EXPECT) if set_expectation'
            method << 'end'
          end

          # puts "\n#{method.inspect}"
          instance_eval(method, __FILE__, __LINE__)
        end
    end
  end
end
