module Compendium
  class MetricSet
    include Enumerable

    delegate :<<, :empty?, :size, :each, to: :@set

    def initialize(set = [])
      @set = set
    end

    def [](metric)
      metric = metric.to_sym
      detect{ |m| m.name.to_sym == metric }
    end

    def except(*metrics)
      metrics.map!(&:to_sym)
      self.class.new(reject{ |m| metrics.include?(m.name.to_sym) })
    end

    def ==(other)
      return @set == other if other.is_a?(Array)
      super
    end
  end
end