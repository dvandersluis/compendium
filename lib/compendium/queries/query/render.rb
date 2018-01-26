module Compendium
  module Queries
    class Query
      module Render
        def render_table(template, *options, &block)
          Compendium::Presenters::Table.new(template, self, *options, &block).render unless empty?
        end

        def render_csv(&block)
          Compendium::Presenters::CSV.new(self, &block).render unless empty?
        end

        def render_chart(template, *options, &block)
          # A query can be rendered regardless of if it has data or not
          # Rendering a chart with no result set builds a chart scaffold which can be updated through AJAX
          chart(template, *options, &block).render
        end

        # Allow access to the chart object without having to explicitly render it
        def chart(template, *options, &block)
          # Access the actual chart object
          Compendium::Presenters::Chart.new(template, self, *options, &block)
        end
      end
    end
  end
end
