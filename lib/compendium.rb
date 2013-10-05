require 'compendium/engine'
require 'compendium/version'
require 'ext/inheritable_attribute'

module Compendium
  autoload :Chart,          'compendium/chart'
  autoload :ContextWrapper, 'compendium/context_wrapper'
  autoload :DSL,            'compendium/dsl'
  autoload :Option,         'compendium/option'
  autoload :Params,         'compendium/params'
  autoload :Query,          'compendium/query'
  autoload :ResultSet,      'compendium/result_set'
  autoload :Report,         'compendium/report'

  autoload :Param,            'compendium/param_types'
  autoload :BooleanParam,     'compendium/param_types'
  autoload :ParamWithChoices, 'compendium/param_types'
  autoload :RadioParam,       'compendium/param_types'

  def self.reports
    @reports ||= []
  end
end
