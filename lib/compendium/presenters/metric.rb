module Compendium
  module Presenters
    class Metric < Base
      presents :metric

      delegate :name, :query, :description, :ran?, to: :metric

      def initialize(template, object, options = {})
        super(template, object)
        @options = options
      end

      def label
        @options[:label] || t("#{query}.#{name}")
      end

      def description
        @options[:description]
      end

      def result(number_format = '%0.1f', display_nil_as = :na)
        if metric.result
          sprintf(number_format, metric.result)
        else
          t(display_nil_as)
        end
      end

      def render
        @template.render 'compendium/reports/metric', metric: self
      end
    end
  end
end
