require 'compendium/param_types/param'

module Compendium
  module ParamTypes
    class Boolean < Param
      def initialize(obj, *)
        value = if obj.numeric? && (0..1).cover?(obj.to_i)
          # If given 0, 1, or a version thereof (ie. "0"), pass it along
          obj.to_i
        else
          obj ? 0 : 1
        end

        super value
      end

      def boolean?
        true
      end

      def value
        [true, false][self]
      end

      # When negating a BooleanParam, use the value instead
      def !
        !value
      end
    end
  end
end
