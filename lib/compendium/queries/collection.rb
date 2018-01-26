require 'compendium/queries/query'

module Compendium
  module Queries
    # A Collection is a Query which runs once for each in a given set of criteria
    class Collection < Query
      attr_accessor :collection

      def initialize(*)
        super
        self.collection = prepare_collection(@options[:collection])
      end

      def run(params, context = self)
        collection_values = get_collection_values(context, params)

        results = collection_values.each_with_object({}) do |(key, value), r|
          res = collect_results(context, params, key, value)
          r[key] = res unless res.empty?
        end

        # A CollectionQuery's results will be a ResultSet of ResultSets
        @results = Compendium::ResultSet.new(results)
      end

    private

      def get_collection_values(context, params)
        self.collection = get_associated_query(collection) if collection.is_a?(Symbol)

        if collection.is_a?(Query)
          collection.run(params, context) unless collection.ran?
          collection.results
        elsif collection.is_a?(Proc)
          prepare_collection(collection.call(params))
        else
          collection
        end
      end

      def prepare_collection(collection)
        return collection if collection.is_a?(Query) || collection.is_a?(Symbol) || collection.is_a?(Proc)
        collection.is_a?(Hash) ? collection : Hash[collection.zip(collection)]
      end
    end
  end
end
