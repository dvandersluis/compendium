# ActiveRecord doesn't know how to handle SimpleDelegators when creating SQL
# This means that when passing a SimpleDelegator (ie. Compendium::Param) into ActiveRecord::Base.find, it'll
# crash.
# Override AR::ConnectionAdapters::Quoting to forward a SimpleDelegator's object to be quoted.

module ActiveRecord
  module ConnectionAdapters
    module Quoting
      def quote_with_simple_delegator(value, column = nil)
        return value.quoted_id if value.respond_to?(:quoted_id)
        value = value.__getobj__ if value.is_a?(SimpleDelegator)
        quote_without_simple_delegator(value, column)
      end

      alias_method_chain :quote, :simple_delegator
    end
  end
end
