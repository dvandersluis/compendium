module Compendium
  module ParamTypes
    class Radio < WithChoices
      def radio?
        true
      end
    end
  end
end
