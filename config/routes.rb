Compendium::Engine.routes.draw do
  scope controller: 'compendium/reports', as: 'compendium_reports' do
    get ':report_name', action: :setup, constraints: { format: :html }, as: 'setup'
    match ':report_name/export(/:query)', action: :export, as: 'export', via: [:get, :post]
    match ':report_name(/:query)', action: :run, as: 'run', via: [:get, :post]
    root action: :index, as: 'root'
  end
end
