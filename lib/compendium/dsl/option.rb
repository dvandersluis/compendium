module Compendium
  module DSL
    module Option
      # Define a parameter for the report
      def option(name, type, default: nil, validates: nil, **opts)
        add_params_validations(name, validates)

        if options[name]
          options[name].type = type
          options[name].default = default if default
          options[name].merge!(opts)
        else
          options << Compendium::Option.new(opts.merge(name: name, type: type, default: default))
        end
      end

      # Each Report will have its own descendant of Params in order to safely add validations
      def params_class
        @params_class ||= Class.new(Params)
      end

      def params_class=(klass)
        @params_class = klass
      end

    private

      def add_params_validations(name, validations)
        return if validations.blank?
        params_class.validates name, validations
      end
    end
  end
end
