module Compendium
  module ParamTypes
    class Date < Param
      def initialize(obj, *)
        obj = if obj.respond_to?(:to_date)
          obj.to_date
        else
          ::Date.parse(obj) rescue nil
        end

        super obj
      end

      def date?
        true
      end
    end
  end
end
