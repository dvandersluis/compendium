require 'collection_of'
require 'inheritable_attr'
require 'compendium/option'
require 'active_support/core_ext/class/attribute'

module Compendium
  module DSL
    def self.extended(klass)
      klass.inheritable_attr :queries, default: ::Collection[Query]
      klass.inheritable_attr :options, default: ::Collection[Option]
    end

    # Define a query
    def query(name, opts = {}, &block)
      define_query(name, opts, &block)
    end
    alias_method :chart, :query
    alias_method :data, :query

    # Define a parameter for the report
    def option(name, *args)
      opts = args.extract_options!
      type = args.shift

      add_params_validations(name, opts.delete(:validates))

      if options[name]
        options[name].type = type if type
        options[name].default = opts.delete(:default) if opts.key?(:default)
        options[name].merge!(opts)
      else
        options << Compendium::Option.new(opts.merge(name: name, type: type))
      end
    end

    # Define a metric from a query or implicitly
    # A metric is a derived statistic from a report, for instance a count of rows
    def metric(name, *args, &block)
      proc = args.first.is_a?(Proc) ? args.first : block
      opts = args.extract_options!

      if opts.key?(:through)
        [opts.delete(:through)].flatten.each do |query|
          raise ArgumentError, "query #{query} is not defined" unless queries.key?(query)
          queries[query].add_metric(name, proc, opts)
        end
      else
        # Allow metrics to define queries implicitly
        # ie. if you need a metric that counts a column, there's no need to explicitly create a query
        # and just pass it into a metric
        query = define_query("__metric_#{name}", {}, &block)
        query.add_metric(name, -> result { result.first }, opts)
      end
    end

    # Define a filter to modify the results from specified query (in this case :deliveries)
    # For example, this can be useful to translate columns prior to rendering, as it will apply
    # for all render types (table, chart, JSON)
    # Multiple queries can be set up with the same filter
    def filter(*query_names, &block)
      each_query(query_names) do |query|
        query.add_filter(block)
      end
    end

    # Allow default table settings to be defined for a query.
    # These settings are used when rendering a query to an HTML table or to CSV
    def table(*query_names, &block)
      each_query(query_names) do |query|
        query.table_settings = block
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

    def each_query(query_names, &block)
      query_names.each do |query_name|
        raise ArgumentError, "query #{query_name} is not defined" unless queries.key?(query_name)
        yield queries[query_name]
      end
    end

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
      elsif opts.fetch(:count, false)
        query_type = CountQuery
      elsif opts.fetch(:sum, false)
        query_type = SumQuery
        params.insert(1, opts[:sum])
      end

      query = query_type.new(*params)
      query.report = self

      metrics[name] = opts[:metric] if opts.key?(:metric)

      if queries[name]
        raise CannotRedefineQueryType unless queries[name].instance_of?(query_type)
        queries.delete(name)
      end

      queries << query

      query
    end

    def add_params_validations(name, validations)
      return if validations.blank?
      self.params_class.validates name, validations
    end
  end
end
