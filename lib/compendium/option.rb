require 'compendium/open_hash'
require 'active_support/string_inquirer'

module Compendium
  class Option
    attr_reader :type
    attr_accessor :name, :default, :choices, :options

    delegate :boolean?, :date?, :dropdown?, :radio?, :scalar?, to: :type
    delegate :merge, :merge!, :[], :[]=, to: :@options

    def initialize(name:, type:, default: nil, choices: nil, **options)
      @name = name.to_sym
      @default = default
      @choices = choices
      @options = options.with_indifferent_access

      self.type = type
    end

    def type=(type)
      @type = ActiveSupport::StringInquirer.new(type.to_s)
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
