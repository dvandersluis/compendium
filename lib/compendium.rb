require 'compendium/engine'
require 'compendium/errors'
require 'compendium/version'
require 'active_support/configurable'
require 'active_support/core_ext'

module Compendium
  autoload :AbstractChartProvider,  'compendium/abstract_chart_provider'
  autoload :ChartProvider,          'compendium/abstract_chart_provider'
  autoload :CollectionQuery,        'compendium/collection_query'
  autoload :ContextWrapper,         'compendium/context_wrapper'
  autoload :CountQuery,             'compendium/count_query'
  autoload :DSL,                    'compendium/dsl'
  autoload :Metric,                 'compendium/metric'
  autoload :Option,                 'compendium/option'
  autoload :Params,                 'compendium/params'
  autoload :Query,                  'compendium/query'
  autoload :ResultSet,              'compendium/result_set'
  autoload :Report,                 'compendium/report'
  autoload :SumQuery,               'compendium/sum_query'
  autoload :ThroughQuery,           'compendium/through_query'

  autoload :Param,                  'compendium/param_types'
  autoload :BooleanParam,           'compendium/param_types'
  autoload :DateParam,              'compendium/param_types'
  autoload :DropdownParam,          'compendium/param_types'
  autoload :ParamWithChoices,       'compendium/param_types'
  autoload :RadioParam,             'compendium/param_types'
  autoload :ScalarParam,            'compendium/param_types'

  def self.reports
    @reports ||= []
  end

  # Configures global settings for Compendium
  #   Compendium.configure do |config|
  #     config.chart_provider = :AmCharts
  #   end
  def self.configure(&block)
    yield @config ||= Compendium::Configuration.new
  end

  def self.config
    @config
  end

  # need a Class for 3.0
  class Configuration #:nodoc:
    include ActiveSupport::Configurable

    config_accessor :chart_provider
  end

  configure do |config|
    config.chart_provider = Compendium::AbstractChartProvider.find_chart_provider
  end
end
