require 'compendium/query'

module Compendium
  # A CollectionQuery is a Query which runs once for each in a given set of criteria
  class CollectionQuery < Query
    attr_accessor :collection

    def initialize(*)
      super
      self.collection = prepare_collection(@options[:collection])
    end

    def run(params, context = self)
      collection_values = get_collection_values(context, params)

      results = collection_values.inject({}) do |r, (key, value)|
        res = collect_results(context, params, value)
        r[key] = res unless res.empty?
        r
      end

      # A CollectionQuery's results will be a ResultSet of ResultSets
      @results = ResultSet.new(results)
    end

  private

    def get_collection_values(context, params)
      self.collection.is_a?(Query) ? self.collection.run(params, context) : self.collection
    end

    def prepare_collection(collection)
      return collection if collection.is_a?(Query)
      return get_associated_query(collection) if collection.is_a?(Symbol)
      collection.is_a?(Hash) ? collection : Hash[collection.zip(collection)]
    end
  end
end
