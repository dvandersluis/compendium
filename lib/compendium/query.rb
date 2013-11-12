require 'compendium/result_set'
require 'compendium/params'
require 'compendium/presenters/chart'
require 'compendium/presenters/table'
require 'collection_of'
require_relative '../../config/initializers/ruby/hash'

module Compendium
  class Query
    attr_reader :name, :results, :metrics
    attr_accessor :options, :proc, :report

    def initialize(*args)
      @report = args.shift if arg_is_report?(args.first)

      raise ArgumentError, "wrong number of arguments (#{args.size + (@report ? 1 : 0)} for 3..4)" unless args.size == 3

      @name, @options, @proc = args
      @metrics = ::Collection[Metric]
    end

    def initialize_clone(*)
      super
      @metrics = @metrics.clone
    end

    def run(params, context = self)
      collect_results(context, params)
      collect_metrics(context)

      @results
    end

    def add_metric(name, proc, options = {})
      Compendium::Metric.new(name, self.name, proc, options).tap { |m| @metrics << m }
    end

    def render_table(template, *options, &block)
      Compendium::Presenters::Table.new(template, self, *options, &block).render unless empty?
    end

    def render_chart(template, *options, &block)
      Compendium::Presenters::Chart.new(template, self, *options, &block).render unless empty?
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
      results.empty?
    end

  private

    def collect_results(context, *params)
      command = context.instance_exec(*params, &proc) if proc
      command = fetch_results(command)
      @results = ResultSet.new(command) if command
    end

    def collect_metrics(context)
      metrics.each{ |m| m.run(context, results) } unless results.empty?
    end

    def fetch_results(command)
      (options.fetch(:collect, nil) == :active_record) ? command : execute_command(command)
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