require 'compendium/query'

module Compendium
  # A SumQuery is a Query which runs an SQL sum statement (with a given column)
  # Often useful in conjunction with a grouped query and counter cache
  # (alternately, see CountQuery)
  class SumQuery < Query
    InvalidCommand = Class.new(StandardError)

    attr_accessor :column

    def initialize(*args)
      @report = args.shift if arg_is_report?(args.first)
      @column = args.slice!(1)
      super(*args)
    end

  private

    def execute_command(command)
      return [] if command.nil?
      raise InvalidCommand unless command.respond_to?(:sum)
      command.sum(column)
    end
  end
end
