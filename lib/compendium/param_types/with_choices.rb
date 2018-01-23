module Compendium
  module ParamTypes
    class WithChoices < Param
      def initialize(obj, choices)
        @choices = choices

        if @choices.respond_to?(:call)
          # If given a proc, defer determining values until later.
          index = obj
        else
          index = obj.numeric? ? obj.to_i : @choices.index(obj)
          raise IndexError if (!obj.nil? && index.nil?) || index.to_i.abs > @choices.length - 1
        end

        super(index)
      end

      def value
        @choices[self]
      end
    end
  end
end
