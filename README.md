# Compendium

Ruby on Rails framework for making reporting easy.

## Usage

Compendium is a reporting framework for Rails which makes it easy to create and render reports (with charts and tables).

A Compendium report is a subclass of `Compendium::Report`. Reports can be defined using the simple DSL:

    class MyReport < Compendium::Report
      # Options define which parameters your report will accept when being set up.
      # An option is defined with a name, a type, and some settings (ie. default value, choices for radio buttons and
      # dropdowns, etc.)
      option :starting_on, :date, default: -> { Date.today - 1.month }
      option :ending_on, :date, default: -> { Date.today }
      option :currency, :radio, choices: [:USD, :CAD, :GBP]

      # By default, queries are converted to SQL and executed instead of returning AR models
      # The query definition block gets the report's current parameters
      # totals: true means that the last row returned should be interpretted as a row of totals
      query :deliveries, totals: true do |params|
        Items.where(delivered: true, purchased_at: (params[:starting_on]..params[:ending_on]))
      end

      # Define a query which collects data by using AR directly
      query :on_hand_inventory, collect: :active_record do |params|
        Items.where(in_stock: true)
      end

      # Define a query that works on another query's result set
      # Note: chart and data are aliases for query
      chart :deliveries_over_time, through: :deliveries do |results|
        results.group_by(&:purchased_at)
      end

      # Queries can also be used to drive metrics
      metric :shipping_time, -> results { results.last['shipping_time'] }, through: :deliveries
    end

Reports can then also be simply instantiated (which is done automatically if using the supplied
`Compendium::ReportsController`):

    report = MyReport.new(starting_on: '2013-06-01')
    report.run(self) # The parameter is the context to run the report in; usually this should be
                     # a controller context so that methods like current_user can be used

Compendium also comes with a variety of different presenters, for rendering the setup page, and displaying charts
(`report.render_chart`), tables (`report.render_table`) and metrics for your report. Charting is delegated through a
`ChartProvider` to a charting gem (amcharts.rb is currently supported).

### Tying into your Rails application

Compendium has a `Rails::Engine`, which adds a default controller and some views. If desired, the controller can be
subclassed so that filters and the like can be added. The controller (which extends `ApplicationController`
automatically) has two actions: `setup` (collect options for the report) and `run` (execute and render the report),
with accompanying views. The `setup` view can be included inside your own view using the `render_report_setup`
method (*NOTE:* you have to pass `local_assigns` into it if you want locals to be passed along).

Routes are not automatically added to your application. In order to do so, you can use the `mount_compendium` helper
within your `config/routes.rb` file

    mount_compendium at: '/report', controller: 'reports' # controller defaults to compendium/reports

### Interaction with other gems
* If [accessible_tooltip](https://github.com/dvandersluis/accessible_tooltip) is present, option notes will be rendered
in a tooltip rather than as straight text.
* [AmCharts.rb](https://github.com/dvandersluis/amcharts.rb) is currently the only chart provider (please create a pull
request if you'd like to create another one...)

## Installation

Add this line to your application's Gemfile:

    gem 'compendium'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install compendium

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Acknowledgments

* Special thanks to [TalentNest](http://github.com/talentnest), who sponsored this gem's development.
