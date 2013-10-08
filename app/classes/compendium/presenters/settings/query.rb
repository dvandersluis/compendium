module Compendium::Presenters::Settings
  class Query
    delegate :[], :fetch, to: :@settings

    def initialize
      @settings = {}.with_indifferent_access
    end

    def method_missing(name, *args, &block)
      if block_given?
        @settings[name] = block.call(*args)
      elsif !args.empty?
        @settings[name] = args.length == 1 ? args.first : args
      elsif name.to_s.end_with?('?')
        prefix = name.to_s.gsub('/\?\z/', '')
        @settings.key?(prefix)
      else
        @settings[name]
      end
    end
  end
end