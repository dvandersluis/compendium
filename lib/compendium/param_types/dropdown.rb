require 'compendium/param_types/with_choices'

module Compendium
  module ParamTypes
    class Dropdown < WithChoices
      def dropdown?
        true
      end
    end
  end
end
