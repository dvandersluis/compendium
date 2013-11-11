require 'compendium/result_set'
require 'compendium/params'
require 'collection_of'
require_relative '../../config/initializers/ruby/hash'

module Compendium
  class Query
    attr_reader :name, :results, :metrics
    attr_accessor :options, :proc, :through, :report

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
      collect_results(params, context)
      collect_metrics(context)

      @results
    end

    def add_metric(name, proc, options = {})
      Compendium::Metric.new(name, self.name, proc, options).tap { |m| @metrics << m }
    end

    def render_table(template, *options, &block)
      Compendium::Presenters::Table.new(template, self, *options, &block).render
    end

    def render_chart(template, *options, &block)
      Compendium::Presenters::Chart.new(template, self, *options, &block).render
    end

    def ran?
      !@results.nil?
    end
    alias_method :has_run?, :ran?

    def nil?
      proc.nil?
    end

  private

    def collect_results(params, context)
      if through.nil?
        args = params
      else
        args = collect_through_query_results(through, params, context)

        # If none of the through queries have any results, we shouldn't try to execute the query, because it
        # depends on the results of its parents.
        return @results = ResultSet.new([]) if args.compact.empty?
      end

      command = context.instance_exec(args, &proc) if proc
      command = fetch_results(command)
      @results = ResultSet.new(command) if command
    end

    def collect_metrics(context)
      metrics.each{ |m| m.run(context, results) } unless results.empty?
    end

    def fetch_results(command)
      if options.key?(:through) or options.fetch(:collect, nil) == :active_record
        command
      else
        execute_command(command)
      end
    end

    def execute_command(command)
      return [] if command.nil?
      command = command.to_sql if command.respond_to?(:to_sql)
      execute_query(command)
    end

    def execute_query(command)
      ::ActiveRecord::Base.connection.select_all(command)
    end

    def collect_through_query_results(through, params, context)
      results = {}

      through = [through].flatten.map(&method(:get_through_query))

      through.each do |q|
        q.run(params, context) unless q.ran?
        results[q.name] = q.results.records
      end

      results = results[through.first.name] if through.size == 1
      results
    end

    def get_through_query(name)
      report.queries[name]
    end

    def arg_is_report?(arg)
      arg.is_a?(Report) or (arg.is_a?(Class) and arg < Report)
    end
  end
end