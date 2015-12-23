# Compendium [![Gem Version](https://badge.fury.io/rb/compendium.svg)](http://badge.fury.io/rb/compendium)

Ruby on Rails framework for making reporting easy.

## Usage

Compendium is a reporting framework for Rails which makes it easy to create and render reports (with charts and tables).

A Compendium report is a subclass of `Compendium::Report`. Reports can be defined using the simple DSL:

```ruby
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

  # Define a filter to modify the results from specified query (in this case :deliveries)
  # For example, this can be useful to translate columns prior to rendering, as it will apply
  # for all render types (table, chart, JSON)
  # Note: A filter can be applied to multiple queries at once
  filter :deliveries do |results, params|
    results.each do |row|
      row['price'] = sprintf('$%.2f', row['price'])
    end
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
```

Reports can then also be simply instantiated (which is done automatically if using the supplied
`Compendium::ReportsController`):

```ruby
report = MyReport.new(starting_on: '2013-06-01')
report.run(self) # The parameter is the context to run the report in; usually this should be
                 # a controller context so that methods like current_user can be used
```

Compendium also comes with a variety of different presenters, for rendering the setup page, and displaying charts
(`report.render_chart`), tables (`report.render_table`) and metrics for your report. Charting is delegated through a
`ChartProvider` to a charting gem (amcharts.rb is currently supported).

### Report Options
Report options are defined by the keyword `option` in your report class. Options must have a name and a type (scalar, boolean, date, dropdown or radio). Additionally, an option can have a default value (given by a proc passed in with the `default:` key), and validations (via the `validates:` key).

In order to specify parameters for the options, pass a hash to `MyReport.new`. Parameters are available via `params`:

```ruby
r = MyReport.new(starting_on: Date.today - 3.months, ending_on: Date.today)
r.params

# {
#   "starting_on"=>Sun, 30 Aug 2015,
#   "ending_on"=>Mon, 30 Nov 2015,
# }
```

#### Validation

If validation is set up on any options, calling `valid?` on the report will validate any given parameters against the validations set up, and will populate an errors object. All validations provided by `ActiveModel::Validations` are available.

```ruby
class MyReport < Compendium::Report
  options :starting_on, :date, validates: { presence: true }
end

r = MyReport.new
r.valid?
# => false

r.errors
# => #<ActiveModel::Errors:0x007fe8359cc6b8
#  @base={"starting_on"=>nil},
#  @messages={:starting_on=>["This field is required."]}>
```

### Query types

Compendium provides a few types of queries in order to make report writing more streamlined.

#### Through Queries

A **through query** lets you use the results of a previous query (or multiple queries) as the basis of your query. This lets you build on another query or combine multiple query's results into a single query. It it specified by passing the `through:` key to `query`, with a query name or array or query names (as symbols).

```ruby
query :dog_sales { |params| Order.where(pet_type: 'dog', created_at: params[:starting_on]..params[:ending_on]) }
query :cat_sales { |params| Order.where(pet_type: 'cat', created_at: params[:starting_on]..params[:ending_on]) }
query :bird_sales { |params| Order.where(pet_type: 'bird', created_at: params[:starting_on]..params[:ending_on]) }

query :total_sales, through: [:dog_sales, :cat_sales, :bird_sales] do |results, params|
  # results is a hash with keys :dog_sales, :cat_sales, :bird_sales
end
```

#### Count Queries

A **count query** simplifies creating a query where you want a count (especially per group of something). A count query is specified by adding `count: true` to the `query` call.

```ruby
query :sales_per_day, count: true do
  Order.group("DATE(created_at)")
end

# results will look something like
# { 2015-10-01 => 4, 2015-10-02 => 20, ... }
```

#### Sum Queries

Like a count query, a **sum query** is useful for performing an aggregate function on a grouped query, in this case summing the results. A sum query is specified by adding <code>sum: <i>:column_name</i></code> to the `query` call.

```ruby
query :commission_per_salesperson, sum: 'commission' do
  # assume commission is a numeric column
  Order.group(:employee_id)
end

# results will be something like
# { 1 => 840.34, 2 => 1065.02, ... }
```

#### Collection Queries

Sometimes you'll want to run a collection over a collection of data; for this, you can use a **collection query**. A collection query will perform the same query for each element of a hash or array, or for each result of a query. A collection is specified via `collection: [...]`, `collection: { ... }` or `collection: query` (note not a symbol but an actual query object).

### Tying into your Rails application

Compendium has a `Rails::Engine`, which adds a default controller and some views. If desired, the controller can be
subclassed so that filters and the like can be added. The controller (which extends `ApplicationController`
automatically) has two actions: `setup` (collect options for the report) and `run` (execute and render the report),
with accompanying views. The `setup` view can be included inside your own view using the `render_report_setup`
method (*NOTE:* you have to pass `local_assigns` into it if you want locals to be passed along).

Routes are not automatically added to your application. In order to do so, you can use the `mount_compendium` helper
within your `config/routes.rb` file

```ruby
mount_compendium at: '/report', controller: 'reports' # controller defaults to compendium/reports
```

### Rendering report results as JSON

While the default action when running a report is to render a view with the results, Compendium reports can be rendered
as JSON. If using the default routes provided by `mount_compendium` (assuming compendium was mounted at `/report`),
`POST`ing to <code>report/<i>report_name</i>.json</code> will return the report results as JSON. You can also collect
the results of a single query (instead of the entire report) by `POST`ing to
<code>report/<i>report_name</i>/<i>query_name</i>.json</code>.

## Displaying Report Results

### Chart Providers

As of 1.1.0, chart providers have been extracted out of the main repository and are available as their own gems. If you want to render queries as a chart, a chart provider gem is needed.

If multiple chart providers are installed, you can select the one you wish you use with the following initializer:

```ruby
Compendium.configure do |config|
  config.chart_provider = :AmCharts # or any other provider name
end
```

The following providers are available (If you would like to contribute a chart provider, please let me know and I'll add it to the list):
* [compendium-amcharts](https://github.com/dvandersluis/compendium-amcharts) - makes use of [AmCharts.rb](https://github.com/dvandersluis/amcharts.rb)

### Rendering a table

In addition to charts, you can output a query as a table. When a query is rendered as a table, each row is output with columns in the query order (so you may want to use an explicit `select` in your query to order the columns as required). If the query is set up with `totals: true`, a totals row will be added to the bottom of the table.

A query is rendered from a view, and is passed in the view context as the first parameter. Optionally, a block can be passed to customize the table:

```ruby
my_query.render_table(self) do |t|
  # Column headings by default are the column name passed through I18n,
  # but can be overridden:

  # ... with a block...
  t.override_heading do |heading|
    # ...
  end

  # ... or one at a time...
  t.override_heading :col, "My Column"

  # Records where a cell is 0 or nil can have the value overridden to something else:
  t.display_zero_as "N/A"
  t.display_nil_as "NULL"

  # You can specify how to format numbers:
  t.number_format "%0.1f"

  # You can also specify formatting on a per-column basis:
  t.format(:col) do |value|
    "#{(value / 50) * 100}%"
  end
end
```

#### CSS Classes

By default, Compendium uses the following four CSS classes when rendering a table:

| Element               | Element Type | Class Name |
|-----------------------|--------------|------------|
| Table                 | `table`      | `results`  |
| Table header          | `tr`         | `headings` |
| Table data            | `tr`         | `data`     |
| Table footer (totals) | `tr`         | `totals`   |

Each class can be overridden when setting up the table:

```ruby
my_query.render_table(self) do |t|
  t.table_class   'my_table_class'
  t.header_class  'my_header_class'
  t.row_class     'my_row_class'
  t.totals_class  'my_totals_class'
end
```

### Interaction with other gems
* If [accessible_tooltip](https://github.com/dvandersluis/accessible_tooltip) is present, option notes will be rendered
in a tooltip rather than as straight text.

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
