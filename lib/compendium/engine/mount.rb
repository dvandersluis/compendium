module ActionDispatch
  module Routing
    class Mapper
      def mount_compendium(options = {})
        scope options[:at], controller: options.fetch(:controller, 'compendium/reports') do
          get ':report_name', action: :setup, as: 'compendium_reports_setup'
          post ':report_name(/:query)', action: :run, as: 'compendium_reports_run'
          root action: :index, as: 'compendium_reports_root'
        end
      end
    end
  end
end