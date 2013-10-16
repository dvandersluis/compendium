module Compendium
  # Abstract wrapper for rendering charts
  # To add a new chart provider, #initialize and #render must be implemented
  class AbstractChartProvider
    attr_reader :chart

    def initialize(type, data, &setup_proc)
      raise NotImplementedError
    end

    def render(template, container)
      raise NotImplementedError
    end
  end

  module ChartProvider
    autoload :AmCharts, 'compendium/chart_provider/amcharts'
  end
end