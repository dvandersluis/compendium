require 'compendium/errors'
require 'compendium/queries/query'

module Compendium
  module Queries
    # A Sum is a Query which runs an SQL sum statement (with a given column)
    # Often useful in conjunction with a grouped query and counter cache
    # (alternately, see Count)
    class Sum < Query
      attr_accessor :column

      def initialize(*args)
        @report = args.shift if arg_is_report?(args.first)
        @column = args.slice!(1)
        super(*args)

        @options.reverse_merge!(order: "SUM(#{@column})", reverse: true)
      end

    private

      def valid_keys
        super.concat([:sum])
      end

      def execute_sql_command(command)
        return [] if command.nil?
        raise InvalidCommand unless command.respond_to?(:sum)
        command.sum(column)
      end
    end
  end
end
