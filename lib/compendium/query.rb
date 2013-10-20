require 'compendium/result_set'
require 'compendium/params'
require 'collection_of'

module Compendium
  class Query
    attr_reader :name, :results, :metrics
    attr_accessor :options, :proc, :through

    def initialize(name, options, proc)
      @name = name
      @options = options
      @proc = proc
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
      args = if through.nil?
        params
      else
        collect_through_query_results(through, params, context)
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
        ::ActiveRecord::Base.connection.select_all(command.respond_to?(:to_sql) ? command.to_sql : command)
      end
    end

    def collect_through_query_results(through, params, context)
      results = {}

      through = [through].flatten

      through.each do |q|
        q.run(params, context) unless q.ran?
        results[q.name] = q.results.records
      end

      results = results[through.first.name] if through.size == 1
      results
    end
  end
end