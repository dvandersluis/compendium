module Compendium::Presenters
  class Metric < Base
    presents :metric

    delegate :name, :query, :ran?, to: :metric

    def label
      t("#{query}.#{name}")
    end

    def result(number_format = '%0.1f', display_nil_as = :na)
      if metric.result
        sprintf(number_format, metric.result)
      else
        t(display_nil_as)
      end
    end
  end
end