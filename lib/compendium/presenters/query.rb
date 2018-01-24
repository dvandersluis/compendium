require 'compendium/presenters/base'
require 'compendium/presenters/settings/query'
require 'compendium/presenters/settings/table'

module Compendium
  module Presenters
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
        Settings::Query
      end
    end
  end
end
