require_relative '../../../config/initializers/ruby/numeric'
require 'delegate'

module Compendium
  module ParamTypes
    class Param < ::SimpleDelegator
      def scalar?
        false
      end

      def boolean?
        false
      end

      def date?
        false
      end

      def dropdown?
        false
      end

      def radio?
        false
      end

      def ==(other)
        return true if (value == other rescue false)
        super
      end

      # Need to explicitly delegate nil? to the object, otherwise it's always false
      # This is because SimpleDelegator is a non-nil object, and it only forwards non-defined methods!
      def nil?
        __getobj__.nil?
      end

      def to_f
        Kernel.Float(__getobj__)
      end

      def to_i
        Kernel.Integer(__getobj__)
      end
    end
  end
end
