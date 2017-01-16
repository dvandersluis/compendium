module ActionDispatch
  module Routing
    class Mapper
      class ExportRouter
        def matches?(request)
          request.params[:export].present?
        end
      end

      def mount_compendium(options = {})
        scope options[:at], controller: options.fetch(:controller, 'compendium/reports'), as: 'compendium_reports' do
          get ':report_name', action: :setup, constraints: { format: :html }, as: 'setup'
          match ':report_name/export', action: :export, as: 'export', via: [:get, :post]
          post ':report_name(/:query)', constraints: ExportRouter.new, action: :export, as: 'export_post'
          match ':report_name(/:query)', action: :run, as: 'run', via: [:get, :post]
          root action: :index, as: 'root'
        end
      end
    end
  end
end
