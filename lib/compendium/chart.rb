require 'compendium/query'

module Compendium
  class Chart < Query
    def chart?
      true
    end

    def table?
      false
    end
  end
end