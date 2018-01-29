require 'compendium/engine'
require 'compendium/errors'
require 'compendium/version'
require 'active_support/configurable'
require 'active_support/core_ext'

module Compendium
  require 'compendium/abstract_chart_provider'
  require 'compendium/abstract_chart_provider'
  require 'compendium/context_wrapper'
  require 'compendium/dsl'
  require 'compendium/engine'
  require 'compendium/metric'
  require 'compendium/option'
  require 'compendium/params'
  require 'compendium/param_types'
  require 'compendium/presenters'
  require 'compendium/queries'
  require 'compendium/result_set'
  require 'compendium/report'

  def self.reports
    @reports ||= []
  end

  # Configures global settings for Compendium
  #   Compendium.configure do |config|
  #     config.chart_provider = :AmCharts
  #   end
  def self.configure
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
