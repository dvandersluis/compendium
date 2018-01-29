module Compendium
  module DSL
    module Table
      # Allow default table settings to be defined for a query.
      # These settings are used when rendering a query to an HTML table or to CSV
      def table(*query_names, &block)
        each_query(query_names) do |query|
          query.table_settings = block
        end
      end
    end
  end
end
