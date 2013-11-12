require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/hash/slice'
require 'compendium/dsl'

module Compendium
  class Report
    attr_accessor :params, :results

    extend Compendium::DSL

    class << self
      def inherited(report)
        Compendium.reports << report
      end

      # Define predicate methods for getting the report type
      # ie. r.spending? checks that r == SpendingReport
      def method_missing(name, *args, &block)
        prefix = name.to_s.gsub(/[?!]\z/, '')
        report_class = "#{prefix}_report".classify.constantize rescue nil

        return self == report_class if name.to_s.end_with?('?') and Compendium.reports.include?(report_class)

        super
      end

      def respond_to_missing?(name, include_private = false)
        prefix = name.to_s.gsub(/[?!]\z/, '')
        report_class = "#{prefix}_report".classify.constantize rescue nil

        return true if name.to_s.end_with?('?') and Compendium.reports.include?(report_class)
        super
      end
    end

    def initialize(params = {})
      @params = Params.new(params, options)

      # When creating a new report, map each query back to the report
      queries.each { |q| q.report = self }
    end

    def run(context = nil, options = {})
      self.context = context
      self.results = {}

      only = options.delete(:only)
      except = options.delete(:except)

      raise ArgumentError, 'cannot specify only and except options at the same time' if only && except
      ([only] + [except]).flatten.compact.each { |q| raise ArgumentError, 'invalid query #{q}' unless queries.include?(q) }

      queries_to_run = if only
        queries.slice(only)
      elsif except
        queries.except(except)
      else
        queries
      end

      queries_to_run.each{ |q| self.results[q.name] = q.run(params, ContextWrapper.wrap(context, self)) }

      self
    end

    def metrics
      Collection[Metric, queries.map{ |q| q.metrics.to_a }.flatten]
    end

  private

    attr_accessor :context

    def method_missing(name, *args, &block)
      prefix = name.to_s.sub(/(?:_results|\?)\Z/, '').to_sym

      return queries[name] if queries.keys.include?(name)
      return results[prefix] if name.to_s.end_with? '_results' and queries.keys.include?(prefix)
      return params[name] if options.keys.include?(name)
      return !!params[prefix] if name.to_s.end_with? '?' and options.keys.include?(prefix)
      super
    end

    def respond_to_missing?(name, include_private = false)
      prefix = name.to_s.sub(/_results\Z/, '').to_sym
      return true if queries.keys.include?(name)
      return true if name.to_s.end_with? '_results' and queries.keys.include?(prefix)
      super
    end
  end
end