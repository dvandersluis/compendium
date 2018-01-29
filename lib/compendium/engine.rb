require 'rails/engine'

module Compendium
  class Engine < Rails::Engine
    config.generators do |g|
      g.test_framework :rspec
    end
  end

  class ExportRouter
    def matches?(request)
      request.params[:export].present?
    end
  end
end
