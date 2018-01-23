require 'compendium/presenters/query'
require 'active_support/core_ext/array/extract_options'

module Compendium::Presenters
  class Chart < Query
    attr_reader :data, :params, :container, :chart_provider
    attr_accessor :options

    def initialize(template, object, *args, &setup)
      super(template, object)

      self.options = args.extract_options!
      type, container = args

      if remote?
        # If the query hasn't run yet, render a chart that loads its data remotely (ie. through AJAX)
        # ie. if rendering a query from a report class directly
        @data = query.url
        @params = collect_params
      else
        @data = options[:index] ? results.records[options[:index]] : results
        @data = @data.records if @data.is_a?(Compendium::ResultSet)
        @data = @data[0...-1] if query.options[:totals]
      end

      @container = container || query.name

      initialize_chart_provider(type, &setup)
    end

    def render
      chart_provider.render(@template, @container)
    end

    # You can force the chart to render remote data, even if the query has already run by passing the remote: true option
    def remote?
      !query.ran? || options.fetch(:remote, false)
    end

  private

    def provider
      provider = Compendium.config.chart_provider
      require "compendium/#{provider.downcase}"
      provider.is_a?(Class) ? provider : Compendium::ChartProvider.const_get(provider)
    end

    def initialize_chart_provider(type, &setup)
      @chart_provider = provider.new(type, @data, @params, &setup)
    end

    def collect_params
      params = {}
      params[:report] = options[:params] if options[:params]

      if remote? && protected_against_csrf?
        # If we're loading remotely, and CSRF protection is enabled,
        # automatically include the CSRF token in AJAX params
        params.merge!(form_authenticity_param)
      end

      params
    end

    def protected_against_csrf?
      @template.controller.send(:protect_against_forgery?)
    end

    def form_authenticity_param
      return {} unless protected_against_csrf?
      { @template.controller.request_forgery_protection_token => @template.controller.send(:form_authenticity_token) }
    end

    def method_missing(name, *args, &block)
      return chart_provider.send(name, *args, &block) if chart_provider.respond_to?(name)
      super
    end

    def respond_to_missing?(name, include_private = false)
      return true if chart_provider.respond_to?(name)
      super
    end
  end
end
