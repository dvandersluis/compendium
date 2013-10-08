require 'active_support/core_ext/module/delegation'

module Compendium
  class ResultSet
    delegate :first, :last, :to_a, :each, :map, :[], :count, :length, :size, :==, to: :records

    attr_reader :records
    alias :all :records

    def initialize(records)
      @records = records
    end

    def keys
      first.keys
    end
  end
end