module Compendium
  module ParamTypes
    class Scalar < Param
      def initialize(obj, *)
        super obj
      end

      # A scalar param just keeps track of a value with no modifications
      def scalar?
        true
      end
    end
  end
end
