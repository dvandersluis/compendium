require 'compendium/errors'
require 'compendium/queries/query'

module Compendium
  module Queries
    # A Count is a Query which runs an SQL count statement
    # Often useful in conjunction with a grouped query
    class Count < Query
      def initialize(*args)
        super

        @options.reverse_merge!(order: 'COUNT(*)', reverse: true)
      end

    private

      def execute_command(command)
        return [] if command.nil?
        raise InvalidCommand unless command.respond_to?(:count)
        command.count
      end
    end
  end
end
