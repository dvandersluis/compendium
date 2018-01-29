module Compendium
  module DSL
    module Query
      # Define a query
      def query(name, opts = {}, &block)
        define_query(name, opts, &block)
      end
      alias_method :chart, :query
      alias_method :data, :query
    end

  private

    def define_query(name, opts, &block)
      params = [name.to_sym, opts, block]

      if opts.key?(:through)
        # Ensure each through query is defined
        through = [opts[:through]].flatten
        through.each { |q| raise ArgumentError, "query #{q} is not defined" unless queries.include?(q.to_sym) }

        params.insert(1, through)
      elsif opts.fetch(:sum, false)
        params.insert(1, opts[:sum])
      end

      query = query_type(opts).new(*params)
      query.report = self

      metrics[name] = opts[:metric] if opts.key?(:metric)

      if queries[name]
        raise Queries::CannotRedefineType unless queries[name].instance_of?(query.class)
        queries.delete(name)
      end

      queries << query

      query
    end

    def query_type(opts)
      klass = if opts.key?(:collection)
        Queries::Collection
      elsif opts.key?(:through)
        Queries::Through
      elsif opts.fetch(:count, false)
        Queries::Count
      elsif opts.fetch(:sum, false)
        Queries::Sum
      else
        opts.delete(:sum)
        Queries::Query
      end

      opts.delete(:count)
      klass
    end
  end
end
