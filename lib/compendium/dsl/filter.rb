module Compendium
  module DSL
    module Filter
      # Define a filter to modify the results from specified query (in this case :deliveries)
      # For example, this can be useful to translate columns prior to rendering, as it will apply
      # for all render types (table, chart, JSON)
      # Multiple queries can be set up with the same filter
      def filter(*query_names, &block)
        each_query(query_names) do |query|
          query.add_filter(block)
        end
      end
    end
  end
end
