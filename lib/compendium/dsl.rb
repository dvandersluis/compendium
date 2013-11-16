require 'collection_of'
require 'inheritable_attr'
require 'compendium/option'
require 'active_support/core_ext/class/attribute'

module Compendium
  module DSL
    def self.extended(klass)
      klass.inheritable_attr :queries, default: ::Collection[Query]
      klass.inheritable_attr :options, default: {}
    end

    def query(name, opts = {}, &block)
      define_query(name, opts, &block)
    end
    alias_method :chart, :query
    alias_method :data, :query

    def option(name, *args)
      opts = args.extract_options!
      type = args.shift

      add_params_validations(name, opts.delete(:validates))

      if options[name]
        options[name].type = type if type
        options[name].default = opts.delete(:default) if opts.key?(:default)
        options[name].merge!(opts)
      else
        options[name] = Compendium::Option.new(opts.merge(name: name, type: type))
      end
    end

    def metric(name, *args, &block)
      proc = args.first.is_a?(Proc) ? args.first : block
      opts = args.extract_options!
      raise ArgumentError, 'through option must be specified for metric' unless opts.key?(:through)

      [opts.delete(:through)].flatten.each do |query|
        raise ArgumentError, "query #{query} is not defined" unless queries.key?(query)
        queries[query].add_metric(name, proc, opts)
      end
    end

    # Each Report will have its own descendant of Params in order to safely add validations
    def params_class
      @params_class ||= Class.new(Params)
    end

    def params_class=(klass)
      @params_class = klass
    end

    # Allow defined queries to be redefined by name, eg:
    # query :main_query
    # main_query { collect_records_here }
    def method_missing(name, *args, &block)
      if queries.keys.include?(name.to_sym)
        query = queries[name.to_sym]
        query.proc = block if block_given?
        query.options = args.extract_options!
        return query
      end

      super
    end

    def respond_to_missing?(name, *args)
      return true if queries.keys.include?(name)
      super
    end

  private

    def define_query(name, opts, &block)
      params = [name.to_sym, opts, block]
      query_type = Query

      if opts.key?(:collection)
        query_type = CollectionQuery
      elsif opts.key?(:through)
        # Ensure each through query is defined
        through = [opts[:through]].flatten
        through.each { |q| raise ArgumentError, "query #{q} is not defined" unless self.queries.include?(q.to_sym) }

        query_type = ThroughQuery
        params.insert(1, through)
      end

      query = query_type.new(*params)

      metrics[name] = opts[:metric] if opts.key?(:metric)
      queries << query
    end

    def add_params_validations(name, validations)
      return if validations.blank?
      self.params_class.validates name, validations
    end
  end
end