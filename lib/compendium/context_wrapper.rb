require 'delegate'

module Compendium
  class ContextWrapper
    def self.wrap(ctx, parent, params = nil, &block)
      delegator = ::SimpleDelegator.new(parent)

      delegator.define_singleton_method(:__context__) { ctx }

      delegator.instance_eval do
        def method_missing(name, *args, &block)
          return __context__.__send__(name, *args, &block) if __context__.respond_to?(name)
          super
        end

        def respond_to_missing?(name, include_private = false)
          return true if __context__.respond_to?(name, include_private)
          super
        end
      end

      return delegator.instance_exec(params, &block) if block_given?

      delegator
    end
  end
end
