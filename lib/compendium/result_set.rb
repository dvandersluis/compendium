require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/indifferent_access'

module Compendium
  class ResultSet
    delegate :first, :last, :to_a, :empty?, :each, :map, :inject, :select, :detect, :[], :count, :length, :size, :==, to: :records

    attr_reader :records
    alias :all :records

    def initialize(records)
      @records = if records.respond_to?(:map)
        records.map do |r|
          r.respond_to?(:with_indifferent_access) ? r.with_indifferent_access : r
        end
      else
        [records]
      end

      @records = Hash[@records] if records.is_a?(Hash)
    end

    def keys
      records.is_a?(Array) ? first.keys : records.keys
    end

    def as_json(options = {})
      return records unless records.first.respond_to?(:except)
      records.map{ |r| r.except(*options[:except]) }
    end
  end
end
