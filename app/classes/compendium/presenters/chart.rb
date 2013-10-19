module Compendium::Presenters
  class Chart < Query
    attr_reader :data, :chart_provider

    def initialize(template, object, type, container = nil, &setup)
      super(template, object)

      @data = results.records
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