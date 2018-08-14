require 'collection_of'
require 'inheritable_attr'

require 'compendium/dsl/exports'
require 'compendium/dsl/filter'
require 'compendium/dsl/metric'
require 'compendium/dsl/option'
require 'compendium/dsl/query'
require 'compendium/dsl/table'
require 'compendium/option'
require 'compendium/queries/query'

require 'active_support/core_ext/class/attribute'

module Compendium
  module DSL
    include Exports
    include Filter
    include Metric
    include Option
    include Query
    include Table

    def self.extended(klass)
      klass.inheritable_attr :queries, default: ::Collection[Queries::Query]
      klass.inheritable_attr :options, default: ::Collection[Compendium::Option]
      klass.inheritable_attr :exporters, default: {}
    end

    # Allow defined queries to be redefined by name, eg:
    # query :main_query
    # main_query { collect_records_here }
    def method_missing(name, *args, &block)
      if queries.key?(name.to_sym)
        query = queries[name.to_sym]
        query.proc = block if block_given?
        query.options = args.extract_options!
        return query
      end

      super
    end

    def respond_to_missing?(name, *args)
      return true if queries.key?(name)
      super
    end

  private

    def each_query(query_names)
      query_names.each do |query_name|
        raise ArgumentError, "query #{query_name} is not defined" unless queries.key?(query_name)
        yield queries[query_name]
      end
    end
  end
end
