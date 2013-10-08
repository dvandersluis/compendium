module Compendium::Presenters
  class Base
    def initialize(template, object)
      @object = object
      @template = template
    end

  private

    def self.presents(name)
      define_method(name) do
        @object
      end
    end

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