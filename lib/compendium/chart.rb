require 'compendium/query'

module Compendium
  class Chart < Query
    CHART_TYPES = [:bar, :column, :pie]

    attr_reader :chart_type, :x_axis, :y_axis

    def initialize(name, options, proc)
      super

      @chart_type = options.fetch(:type, CHART_TYPES.first)
      @x_axis = options.fetch(:x_axis, "")
      @y_axis = options.fetch(:y_axis, "")

      raise ArgumentError, "type must be one of #{CHART_TYPES.join(', ')}" unless CHART_TYPES.include?(@chart_type)
    end

    def chart?
      true
    end

    def table?
      false
    end
  end
end