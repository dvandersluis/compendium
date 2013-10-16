require 'compendium/engine'
require 'compendium/version'
require 'ext/inheritable_attribute'

module Compendium
  autoload :AbstractChartProvider,  'compendium/abstract_chart_provider'
  autoload :ChartProvider,          'compendium/abstract_chart_provider'
  autoload :ContextWrapper,         'compendium/context_wrapper'
  autoload :DSL,                    'compendium/dsl'
  autoload :MetricSet,              'compendium/metric_set'
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
end
