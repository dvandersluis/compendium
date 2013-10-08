module Compendium::Presenters
  class Query < Base
    presents :query

    def initialize(template, object, &setup)
      super(template, object)

      @settings = settings_class.new(results.keys)
      yield @settings if block_given?
    end

    def render
      raise NotImplementedError
    end

  private

    def settings_class
      Settings.const_get(self.class.name.demodulize) rescue Settings::Query
    end
  end
end