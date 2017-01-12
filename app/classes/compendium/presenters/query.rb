require 'compendium/presenters/base'
require 'compendium/presenters/settings/query'
require 'compendium/presenters/settings/table'

module Compendium::Presenters
  class Query < Base
    presents :query

    def initialize(template, object)
      super(template, object)
    end

    def render
      raise NotImplementedError
    end

  private

    def results
      query.results
    end

    def settings_class
      Settings.const_get(self.class.name.demodulize, false) rescue Settings::Query
    end
  end
end
