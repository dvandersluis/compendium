require 'compendium/query'

module Compendium
  class ThroughQuery < Query
    attr_accessor :through

    def initialize(*args)
      @report = args.shift if arg_is_report?(args.first)
      @through = args.slice!(1)
      super(*args)
    end

  private

    def collect_results(context, params)
      args = collect_through_query_results(params, context)

      # If none of the through queries have any results, we shouldn't try to execute the query, because it
      # depends on the results of its parents.
      return @results = ResultSet.new([]) if args.compact.empty?

      super(context, args)
    end

    def fetch_results(command)
      command
    end

    def collect_through_query_results(params, context)
      results = {}

      queries = [through].flatten.map(&method(:get_associated_query))

      queries.each do |q|
        q.run(params, context) unless q.ran?
        results[q.name] = q.results.records
      end

      results = results[queries.first.name] if queries.size == 1
      results
    end
  end
end
