require 'compendium/engine'
require 'compendium/version'
require 'active_support/configurable'

module Compendium
  autoload :AbstractChartProvider,  'compendium/abstract_chart_provider'
  autoload :ChartProvider,          'compendium/abstract_chart_provider'
  autoload :ContextWrapper,         'compendium/context_wrapper'
  autoload :DSL,                    'compendium/dsl'
  autoload :Metric,                 'compendium/metric'
  autoload :Option,                 'compendium/option'
  autoload :Params,                 'compendium/params'
  autoload :Query,                  'compendium/query'
  autoload :ResultSet,              'compendium/result_set'
  autoload :Report,                 'compendium/report'

  autoload :Param,                  'compendium/param_types'
  autoload :BooleanParam,           'compendium/param_types'
  autoload :ParamWithChoices,       'compendium/param_types'
  autoload :RadioParam,             'compendium/param_types'

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
