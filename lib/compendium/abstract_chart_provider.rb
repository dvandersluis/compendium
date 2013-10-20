require 'active_support/core_ext/string/inflections'

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

    # As more chart providers are added, this method will have to be extended to find them
    def self.find_chart_provider
      if defined?(AmCharts)
        :AmCharts
      else
        self.name.demodulize.to_sym
      end
    end
  end

  module ChartProvider
    autoload :AmCharts, 'compendium/chart_provider/amcharts'
  end
end