require 'compendium/queries/query'

module Compendium
  module Queries
    # A Through is a Query which distills data from previously run queries (one or multiple)
    class Through < Query
      attr_accessor :through

      def initialize(*args)
        @report = args.shift if arg_is_report?(args.first)
        @through = args.slice!(1)
        super(*args)
      end

    private

      def collect_results(context, params)
        results = collect_through_query_results(params, context)

        # If none of the through queries have any results, we shouldn't try to execute the query, because it
        # depends on the results of its parents.
        return @results = Compendium::ResultSet.new([]) if any_results?(results)

        # If the proc collects two arguments, pass results and params, otherwise just results
        args = !proc || proc.arity == 1 ? [results] : [results, params]

        super(context, *args)
      end

      def fetch_results(command)
        command
      end

      def collect_through_query_results(params, context)
        results = {}

        queries = Array.wrap(through).map(&method(:get_associated_query))

        queries.each do |q|
          q.run(params, context) unless q.ran?
          results[q.name] = q.results.records.dup
        end

        results = results[queries.first.name] if queries.size == 1
        results
      end

      def any_results?(results)
        results = results.values if results.is_a? Hash
        results.all?(&:blank?)
      end
    end
  end
end
