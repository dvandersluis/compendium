require 'compendium/result_set'
require 'compendium/params'
require 'compendium/metric'
require 'compendium/presenters/chart'
require 'compendium/presenters/table'
require 'collection_of'
require_relative '../../config/initializers/ruby/hash'

module Compendium
  class Query
    attr_reader :name, :results, :metrics, :filters
    attr_accessor :options, :proc, :report

    def initialize(*args)
      @report = args.shift if arg_is_report?(args.first)

      raise ArgumentError, "wrong number of arguments (#{args.size + (@report ? 1 : 0)} for 3..4)" unless args.size == 3

      @name, @options, @proc = args
      @metrics = ::Collection[Metric]
      @filters = ::Collection[Proc]
    end

    def initialize_clone(*)
      super
      @metrics = @metrics.clone
    end

    def run(params, context = self)
      if report.is_a?(Class)
        # If running a query directly from a class rather than an instance, the class's query should
        # not be affected/modified, so run the query without a reference back to the report.
        # Otherwise, if the class is subsequently instantiated, the instance will already have results.
        dup.tap{ |q| q.report = nil }.run(params, context)
      else
        collect_results(context, params)
        collect_metrics(context)

        @results
      end
    end

    # Get a URL for this query (format: :json set by default)
    def url(params = {})
      report.url(params.merge(query: self.name))
    end

    def add_metric(name, proc, options = {})
      Compendium::Metric.new(name, self.name, proc, options).tap { |m| @metrics << m }
    end

    def add_filter(filter)
      @filters << filter
    end

    def render_table(template, *options, &block)
      Compendium::Presenters::Table.new(template, self, *options, &block).render unless empty?
    end

    # Allow access to the chart object without having to explicitly render it
    def chart(template, *options, &block)
      # Access the actual chart object
      Compendium::Presenters::Chart.new(template, self, *options, &block)
    end

    def render_chart(template, *options, &block)
      # A query can be rendered regardless of if it has data or not
      # Rendering a chart with no result set builds a chart scaffold which can be updated through AJAX
      chart(template, *options, &block).render
    end

    def ran?
      !@results.nil?
    end
    alias_method :has_run?, :ran?

    # A query is nil if it has no proc
    def nil?
      proc.nil?
    end

    # A query is empty if it has no results
    def empty?
      results.blank?
    end

  private

    def collect_results(context, *params)
      command = context.instance_exec(*params, &proc) if proc
      results = fetch_results(command)
      results = filter_results(results, *params) if filters.any?
      @results = ResultSet.new(results) if results
    end

    def collect_metrics(context)
      metrics.each{ |m| m.run(context, results) } unless results.empty?
    end

    def fetch_results(command)
      (options.fetch(:collect, nil) == :active_record) ? command : execute_command(command)
    end

    def filter_results(results, params)
      return unless results

      filters.each do |f|
        if f.arity == 2
          results = f.call(results, params)
        else
          results = f.call(results)
        end
      end

      results
    end

    def execute_command(command)
      return [] if command.nil?
      command = command.to_sql if command.respond_to?(:to_sql)
      execute_query(command)
    end

    def execute_query(command)
      ::ActiveRecord::Base.connection.select_all(command)
    end

    def arg_is_report?(arg)
      arg.is_a?(Report) or (arg.is_a?(Class) and arg < Report)
    end

    def get_associated_query(query)
      query.is_a?(Query) ? query : report.queries[query]
    end
  end
end