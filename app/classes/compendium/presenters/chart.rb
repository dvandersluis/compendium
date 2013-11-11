require 'compendium/presenters/query'

module Compendium::Presenters
  class Chart < Query
    attr_reader :data, :chart_provider

    def initialize(template, object, type, container = nil, &setup)
      super(template, object)

      @data = results.records
      @data = @data[0...-1] if query.options[:totals]

      @container = container || query.name

      initialize_chart_provider(type, &setup)
    end

    def render
      chart_provider.render(@template, @container)
    end

  private

    def provider
      provider = Compendium.config.chart_provider
      provider.is_a?(Class) ? provider : Compendium::ChartProvider.const_get(provider)
    end

    def initialize_chart_provider(type, &setup)
      @chart_provider = provider.new(type, @data, &setup)
    end
  end
end