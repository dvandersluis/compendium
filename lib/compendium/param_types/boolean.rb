module Compendium
  module ParamTypes
    class Boolean < Param
      def initialize(obj, *)
        # If given 0, 1, or a version thereof (ie. "0"), pass it along
        return super obj.to_i if obj.numeric? && (0..1).cover?(obj.to_i)
        super !!obj ? 0 : 1
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
