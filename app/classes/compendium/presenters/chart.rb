require 'compendium/presenters/query'
require 'active_support/core_ext/array/extract_options'

module Compendium::Presenters
  class Chart < Query
    attr_reader :data, :container, :chart_provider

    def initialize(template, object, *args, &setup)
      options = args.extract_options!
      type, container = args

      super(template, object)

      @data = options[:index] ? results.records[options[:index]] : results
      @data = @data.records if @data.is_a?(Compendium::ResultSet)
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