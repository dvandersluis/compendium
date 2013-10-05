require 'compendium/option'
require 'active_support/core_ext/class/attribute'

module Compendium
  module DSL
    def self.extended(klass)
      klass.inheritable_attr :queries, :options, default: {}
      klass.inheritable_attr :metrics, default: []
    end

    def query(name, opts = {}, &block)
      define_query(name, opts, &block)
    end

    def chart(name, opts = {}, &block)
      define_query(name, opts, Chart, &block)
    end

    def option(name, *args)
      opts = args.extract_options!
      type = args.shift

      if self.options[name]
        self.options[name].type = type if type
        self.options[name].merge!(opts)
      else
        self.options[name] = Compendium::Option.new(opts.merge(name: name, type: type))
      end
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

    def define_query(name, opts, type = Query, &block)
      name = name.to_sym
      query = type.new(name, opts, block)

      if opts.key?(:through)
        raise ArgumentError, "query #{opts[:through]} is not defined" unless self.queries.include?(opts[:through].to_sym)
        query.through = self.queries[opts[:through]]
      end

      if opts.key?(:metric)
        self.metrics << name
      end

      self.queries[name] = query
    end
  end
end