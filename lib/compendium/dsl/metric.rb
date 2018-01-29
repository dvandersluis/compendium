module Compendium
  module DSL
    module Metric
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
          query.add_metric(name, -> (result) { result.first }, opts)
        end
      end
    end
  end
end
