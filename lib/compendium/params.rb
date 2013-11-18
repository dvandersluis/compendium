require 'compendium/open_hash'
require 'compendium/param_types'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'
require 'active_model'

module Compendium
  class Params < OpenHash
    include ActiveModel::Validations

    attr_reader :options

    def initialize(hash = {}, options = {})
      @options = options
      super(prepare_hash_from_options(hash))
    end

    def self.model_name
      ActiveModel::Name.new(Compendium::Params, Compendium, 'compendium.params')
    end

  protected

    def prepare_hash_from_options(params)
      params = params.slice(*options.keys)

      options.each do |option|
        begin
          klass = "Compendium::#{"#{option.type}Param".classify}".constantize
          params[option.name] = klass.new(get_default_value(params[option.name], option.default), option.choices)
        rescue IndexError
          raise IndexError, "invalid index for #{option_name}"
        end
      end

      params
    end

    def get_default_value(current, default)
      if current.blank? and !default.blank?
        default.respond_to?(:call) ? default.call : default
      else
        current
      end
    end
  end
end