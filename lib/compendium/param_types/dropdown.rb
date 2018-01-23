module Compendium
  module ParamTypes
    class Dropdown < WithChoices
      def dropdown?
        true
      end
    end
  end
end
