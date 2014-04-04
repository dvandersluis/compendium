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

    # Chart providers need to override this method to add a hook for themselves
    def self.find_chart_provider
      nil
    end
  end
end