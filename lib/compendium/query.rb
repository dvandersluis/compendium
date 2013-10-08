require 'compendium/result_set'
require 'compendium/params'

module Compendium
  class Query
    attr_reader :name, :results
    attr_accessor :options, :proc, :through

    def initialize(name, options, proc)
      @name = name
      @options = options
      @proc = proc
      @metric = options.fetch(:metric, nil)
    end

    def run(params, context = self)
      collect_results(params, context)
      collect_metric(context) if @metric

      @results
    end

    def render_table(template, &block)
      Compendium::Presenters::Table.new(template, self, &block).render
    end

    def render_chart(template, &block)
      Compendium::Presenters::Chart.new(template, self, &block).render
    end

    def ran?
      !@results.nil?
    end

    def metric
      @metric_result
    end

    def nil?
      proc.nil?
    end

    def chart?
      true
    end

    def table?
      true
    end

    def set_metric(metric)
      @metric = options[:metric] = metric
    end

  private

    def collect_results(params, context)
      if through.nil?
        args = params
      else
        through.run(params, context) unless through.ran?
        args = through.results.records
      end

      command = context.instance_exec(args, &proc) if proc
      command = fetch_results(command)
      @results = ResultSet.new(command) if command
    end

    def collect_metric(context)
      if @metric.is_a?(Symbol)
        @metric_result = context.send(@metric, @results)
      else
        @metric_result = context.instance_exec(@results, &@metric) if @metric
      end
    end

    def fetch_results(command)
      if options.key?(:through) or options.fetch(:collect, nil) == :active_record
        command
      else
        ::ActiveRecord::Base.connection.select_all(command.respond_to?(:to_sql) ? command.to_sql : command)
      end
    end
  end
end