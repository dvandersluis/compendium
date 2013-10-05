require 'active_support/core_ext/object/duplicable'
require 'active_support/core_ext/array/extract_options'

module InheritableAttribute
  # Creates an inheritable attribute with accessors in the singleton class. Derived classes inherit the
  # attributes. This is especially helpful with arrays or hashes that are extended in the inheritance
  # chain. Note that you have to initialize the inheritable attribute.
  # Based on https://github.com/apotonick/hooks/blob/master/lib/hooks/inheritable_attribute.rb
  #
  # Example:
  #
  #   class Cat
  #     inheritable_attr :drinks
  #     self.drinks = ["Becks"]
  #
  #   class Garfield < Cat
  #     self.drinks << "Fireman's 4"
  #
  # and then, later
  #
  #   Cat.drinks      #=> ["Becks"]
  #   Garfield.drinks #=> ["Becks", "Fireman's 4"]
  def inheritable_attr(*names)
    raise ArgumentError, 'at least one attribute must be specified' if names.empty?

    options = names.extract_options!

    names.each do |name|
      instance_eval %{
        def #{name}=(v)
          @#{name} = v
        end

        def #{name}
          return @#{name} unless superclass.respond_to?(:#{name}) and value = superclass.#{name}
          initial = value.duplicable? ? value.clone : value
          defined?(@#{name}) ? @#{name} : @#{name} = initial
        end
      }

      class_eval %{
        def #{name}
          self.class.#{name}
        end
      } if options.fetch(:instance_reader, true)

      class_eval %{
        def #{name}=(v)
          self.class.#{name} = v
        end
      } if options.fetch(:instance_writer, true)

      send(:"#{name}=", options[:default]) if options.key?(:default)
    end
  end
end

Class.send(:include, InheritableAttribute)