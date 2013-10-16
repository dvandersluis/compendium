module Compendium
  module ChartProvider
    # Uses the amcharts.rb gem to provide charting
    class AmCharts < Compendium::AbstractChartProvider
      def initialize(type, data, &setup_proc)
        @chart = chart_class(type).new(data, &setup_proc)
      end

      def render(template, container)
        template.amchart(chart, container)
      end

    private

      def chart_class(type)
        ::AmCharts::Chart.const_get(type.to_s.titlecase)
      end
    end
  end
end