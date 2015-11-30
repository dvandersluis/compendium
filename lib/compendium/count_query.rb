require 'compendium/query'

module Compendium
  # A CountQuery is a Query which runs an SQL count statement
  # Often useful in conjunction with a grouped query
  class CountQuery < Query

  private

    def execute_command(command)
      return [] if command.nil?
      raise InvalidCommand unless command.respond_to?(:count)
      command.count
    end
  end
end
