module Compendium
  module DSL
    module Option
      # Define a parameter for the report
      def option(name, *args)
        opts = args.extract_options!
        type = args.shift

        add_params_validations(name, opts.delete(:validates))

        if options[name]
          options[name].type = type if type
          options[name].default = opts.delete(:default) if opts.key?(:default)
          options[name].merge!(opts)
        else
          options << Compendium::Option.new(opts.merge(name: name, type: type))
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
