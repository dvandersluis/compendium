module Compendium
  Metric = Struct.new(:name, :query, :command, :options) do
    attr_accessor :result

    def initialize(*)
      super
      self.options ||= {}
    end

    def run(ctx, data)
      self.result = if condition_failed?(ctx)
        nil
      else
        command.is_a?(Symbol) ? ctx.send(command, data) : ctx.instance_exec(data, &command)
      end
    end

    def ran?
      !result.nil?
    end
    alias_method :has_ran?, :ran?

    def render(template, *options, &block)
      Compendium::Presenters::Metric.new(template, self, *options, &block).render
    end

  private

    def condition_failed?(ctx)
      (options.key?(:if) && !ctx.instance_exec(&options[:if])) || (options.key?(:unless) && ctx.instance_exec(&options[:unless]))
    end
  end
end
