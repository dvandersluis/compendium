require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/indifferent_access'

module Compendium
  module Presenters
    module Settings
      class Query
        attr_reader :query

        delegate :[], :fetch, to: :@settings
        delegate :report, to: :query, allow_nil: true

        def initialize(query = nil)
          @settings = {}.with_indifferent_access
          @query = query
        end

        def update(&block)
          instance_exec(self, &block)
        end

        def method_missing(name, *args, &block)
          if block_given?
            @settings[name] = block.call(*args)
          elsif !args.empty?
            @settings[name] = args.length == 1 ? args.first : args
          elsif name.to_s.end_with?('?')
            prefix = name.to_s.gsub(/\?\z/, '')
            @settings.key?(prefix)
          else
            @settings[name]
          end
        end
      end
    end
  end
end
