module Compendium
  module DSL
    module Exports
      # Define any exports the report has
      def exports(type, *opts)
        exporters[type] = if opts.empty?
          true
        elsif opts.length == 1
          opts.first
        else
          opts
        end
      end
    end
  end
end
