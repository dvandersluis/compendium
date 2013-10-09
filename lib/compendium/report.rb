require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/hash/slice'
require 'compendium/dsl'

module Compendium
  class Report
    attr_accessor :params, :results

    extend Compendium::DSL

    def self.inherited(report)
      Compendium.reports << report
    end

    def initialize(params = {})
      @params = Params.new(params, options)
    end

    def run(context = nil)
      self.context = context
      self.results = {}
      queries.values.each{ |q| self.results[q.name] = q.run(params, ContextWrapper.wrap(context, self)) }
      self
    end

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

  private

    attr_accessor :context

  end
end