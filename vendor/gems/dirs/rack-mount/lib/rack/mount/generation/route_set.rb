require 'rack/mount/utils'
require 'forwardable'

module Rack::Mount
  module Generation
    module RouteSet
      # Adds generation related concerns to RouteSet.new.
      def initialize(*args)
        @named_routes = {}
        @generation_key_analyzer = Analysis::Frequency.new

        super
      end

      # Adds generation aspects to RouteSet#add_route.
      def add_route(*args)
        route = super
        @named_routes[route.name] = route if route.name
        @generation_key_analyzer << route.generation_keys
        route
      end

      # Generates path from identifiers or significant keys.
      #
      # To generate a url by named route, pass the name in as a +Symbol+.
      #   url(:dashboard) # => "/dashboard"
      #
      # Additional parameters can be passed in as a hash
      #   url(:people, :id => "1") # => "/people/1"
      #
      # If no name route is given, it will fall back to a slower
      # generation search.
      #   url(:controller => "people", :action => "show", :id => "1")
      #     # => "/people/1"
      def url(*args)
        named_route, params, recall = extract_params!(*args)

        params = URISegment.wrap_values(params)
        recall = URISegment.wrap_values(recall)

        unless result = generate(:path_info, named_route, params, recall)
          return
        end

        uri, params = result
        params.each do |k, v|
          if v._value
            params[k] = v._value
          else
            params.delete(k)
          end
        end

        uri << "?#{Utils.build_nested_query(params)}" if uri && params.any?
        uri
      end

      def generate(method, *args) #:nodoc:
        raise 'route set not finalized' unless @generation_graph

        named_route, params, recall = extract_params!(*args)
        merged = recall.merge(params)
        route = nil

        if named_route
          if route = @named_routes[named_route.to_sym]
            recall = route.defaults.merge(recall)
            url = route.generate(method, params, recall)
            [url, params]
          else
            raise RoutingError, "#{named_route} failed to generate from #{params.inspect}"
          end
        else
          keys = @generation_keys.map { |key|
            if k = merged[key]
              k.to_s
            else
              nil
            end
          }
          @generation_graph[*keys].each do |r|
            if url = r.generate(method, params, recall)
              return [url, params]
            end
          end

          raise RoutingError, "No route matches #{params.inspect}"
        end
      end

      def rehash #:nodoc:
        @generation_keys  = build_generation_keys
        @generation_graph = build_generation_graph

        super
      end

      private
        def expire!
          @generation_keys = @generation_graph = nil
          super
        end

        def build_generation_graph
          build_nested_route_set(@generation_keys) { |k, i|
            if k = @generation_key_analyzer.possible_keys[i][k]
              k.to_s
            else
              nil
            end
          }
        end

        def build_generation_keys
          @generation_key_analyzer.report
        end

        def extract_params!(*args)
          case args.length
          when 3
            named_route, params, recall = args
          when 2
            if args[0].is_a?(Hash) && args[1].is_a?(Hash)
              params, recall = args
            else
              named_route, params = args
            end
          when 1
            if args[0].is_a?(Hash)
              params = args[0]
            else
              named_route = args[0]
            end
          else
            raise ArgumentError
          end

          named_route ||= nil
          params ||= {}
          recall ||= {}

          [named_route, params.dup, recall.dup]
        end

        class URISegment < Struct.new(:_value)
          def self.wrap_values(hash)
            hash.inject({}) { |h, (k, v)| h[k] = new(v); h }
          end

          extend Forwardable
          def_delegators :_value, :==, :eql?, :hash

          def to_param
            @to_param ||= begin
              v = _value.respond_to?(:to_param) ? _value.to_param : _value
              Utils.escape_uri(v)
            end
          end
          alias_method :to_s, :to_param
        end
    end
  end
end
