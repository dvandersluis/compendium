require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'compendium/dsl'

module Compendium
  class Report
    attr_accessor :params, :results

    extend Compendium::DSL

    delegate :valid?, :errors, to: :params
    delegate :report_name, :url, to: 'self.class'

    class << self
      delegate :validate, to: :params_class
      
      def inherited(report)
        Compendium.reports << report

        # Each Report object has its own Params class so that validations can be added without affecting other
        # reports. However, validations also need to be inherited, so when inheriting a report, subclass its
        # params_class
        report.params_class = Class.new(self.params_class)
        report.params_class.class_eval %Q{
          def self.model_name
            ActiveModel::Name.new(Compendium::Params, Compendium, "compendium.params.#{report.name.underscore rescue 'report'}")
          end
        }
      end

      def report_name
        name.underscore.gsub(/_report$/,'').to_sym
      end

      # Get a URL for this report (format: :json set by default)
      def url(params = {})
        path_helper(params)
      end

      # Define predicate methods for getting the report type
      # ie. r.spending? checks that r == SpendingReport
      def method_missing(name, *args, &block)
        prefix = name.to_s.gsub(/[?!]\z/, '')
        report_class = "#{prefix}_report".classify.constantize rescue nil

        return self == report_class if name.to_s.end_with?('?') && Compendium.reports.include?(report_class)

        super
      end

      def respond_to_missing?(name, include_private = false)
        prefix = name.to_s.gsub(/[?!]\z/, '')
        report_class = "#{prefix}_report".classify.constantize rescue nil

        return true if name.to_s.end_with?('?') && Compendium.reports.include?(report_class)
        super
      end

    private

      def path_helper(params)
        raise ActionController::RoutingError, "compendium_reports_run_path must be defined" unless route_helper_defined?
        Rails.application.routes.url_helpers.compendium_reports_run_path(self.report_name, params.reverse_merge(format: :json))
      end

      def route_helper_defined?
        @route_helpers ||= Module.new { include Rails.application.routes.url_helpers }
        @route_helpers.method_defined?(:compendium_reports_run_path)
      end
    end

    def initialize(params = {})
      @params = self.class.params_class.new(params, options)

      # When creating a new report, map each query back to the report
      queries.each { |q| q.report = self }
    end

    def run(context = nil, options = {})
      self.context = context
      self.results = {}

      only = [options.delete(:only)].flatten.compact
      except = [options.delete(:except)].flatten.compact

      raise ArgumentError, 'cannot specify only and except options at the same time' if !only.empty? && !except.empty?
      (only + except).flatten.each { |q| raise ArgumentError, "invalid query #{q}" unless queries.include?(q) }

      queries_to_run = if !only.empty?
        queries.slice(*only)
      elsif !except.empty?
        queries.except(*except)
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
      return results[prefix] if name.to_s.end_with?('_results') && queries.keys.include?(prefix)
      return params[name] if options.keys.include?(name)
      return !!params[prefix] if name.to_s.end_with?('?') && options.keys.include?(prefix)
      super
    end

    def respond_to_missing?(name, include_private = false)
      prefix = name.to_s.sub(/_results\Z/, '').to_sym
      return true if queries.keys.include?(name)
      return true if name.to_s.end_with?('_results') && queries.keys.include?(prefix)
      super
    end
  end
end