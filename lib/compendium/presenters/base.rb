module Compendium::Presenters
  class Base
    def self.presents(name)
      define_method(name) do
        @object
      end
    end

    def initialize(template, object)
      @object = object
      @template = template
    end

    def to_s
      "#<#{self.class.name}:0x00#{'%x' % (object_id << 1)}>"
    end

  private

    def method_missing(*args, &block)
      return @template.send(*args, &block) if @template.respond_to?(args.first)
      super
    end

    def respond_to_missing?(*args)
      return true if @template.respond_to?(*args)
      super
    end
  end
end
