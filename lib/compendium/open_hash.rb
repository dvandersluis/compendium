require 'active_support/hash_with_indifferent_access'

module Compendium
  class OpenHash < ::HashWithIndifferentAccess
    class << self
      def [](hash = {})
        new(hash)
      end
    end

    def dup
      self.class.new(self)
    end

  protected

    def convert_value(value)
      if value.is_a? Hash
        Params[value].tap do |oh|
          oh.each do |k, v|
            oh[k] = convert_value(v) if v.is_a? Hash
          end
        end
      elsif value.is_a?(Array)
        value.dup.replace(value.map { |e| convert_value(e) })
      else
        value
      end
    end

    def method_missing(name, *args, &block)
      method = name.to_s

      case method
        when %r{.=$}
          super unless args.length == 1
          return self[method[0...-1]] = args.first

        when %r{.\?$}
          super unless args.empty?
          return self.key?(method[0...-1].to_sym)

        when %r{^_.}
          super unless args.empty?
          return self[method[1..-1]] if self.key?(method[1..-1].to_sym)

        else
          return self[method] if key?(method) || !respond_to?(method)
      end

      super
    end

    def respond_to_missing?(name, include_private = false)
      method = name.to_s

      case method
        when %r{.[=?]$}
          return true if self.key?(method[0...-1])

        when %r{^_.}
          return true if self.key?(method[1..-1])
      end

      super
    end
  end
end
