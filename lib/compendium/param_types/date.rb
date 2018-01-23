module Compendium
  module ParamTypes
    class Date < Param
      def initialize(obj, *)
        if obj.respond_to?(:to_date)
          obj = obj.to_date
        else
          obj = ::Date.parse(obj) rescue nil
        end

        super obj
      end

      def date?
        true
      end
    end
  end
end
