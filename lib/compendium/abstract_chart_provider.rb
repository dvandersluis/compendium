require 'active_support/core_ext/string/inflections'

module Compendium
  # Abstract wrapper for rendering charts
  # To add a new chart provider, #initialize and #render must be implemented
  # Custom providers should also override Compendium::AbstractChartProvider.find_chart_provider (but fallback to super)

  class AbstractChartProvider
    attr_reader :chart

    # @param type [Symbol] The type of chart you want to render (:pie, :line, etc).
    #   Accepted types might vary by provider.
    # @param data_or_url [Enumerable or String] The data or URL to the data you wish to render.
    #   Providers may not support loading data remotely.
    # @param params [Hash] If data_or_url is a URL, the params to use for the AJAX request
    def initialize(type, data_or_url, params = {}, &setup_proc)
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