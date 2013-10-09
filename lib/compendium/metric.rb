module Compendium
  Metric = Struct.new(:name, :query, :command, :options) do
    attr_accessor :result

    def initialize(*)
      super
      self.options ||= {}
    end

    def run(ctx, data)
      return if options.key?(:if) and !ctx.instance_exec(&options[:if])
      return if options.key?(:unless) and ctx.instance_exec(&options[:unless])

      self.result = command.is_a?(Symbol) ? ctx.send(command, data) : ctx.instance_exec(data, &command)
    end

    def ran?
      !result.nil?
    end
    alias_method :has_ran?, :ran?
  end
end