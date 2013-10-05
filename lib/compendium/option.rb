require 'compendium/open_hash'
require 'active_support/string_inquirer'
require 'active_support/core_ext/hash/indifferent_access'

module Compendium
  class Option
    attr_reader :name, :type, :default, :options

    delegate :boolean?, :date?, :dropdown?, :radio?, :text?, to: :type
    delegate :merge, :merge!, :[], to: :@options

    def initialize(hash = {})
      @name = hash.delete(:name).to_sym
      @default = hash.delete(:default)
      @type = ActiveSupport::StringInquirer.new(hash.delete(:type).to_s)
      @options = hash.with_indifferent_access
    end

    def method_missing(name, *args, &block)
      return options[name] if options.key?(name)
      return options.key?(name[0...-1]) if name.to_s.end_with?('?')
      super
    end

    def respond_to_missing?(name, include_private = false)
      return true if options.key?(name)
      super
    end
  end
end