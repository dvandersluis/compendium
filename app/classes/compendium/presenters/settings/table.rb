module Compendium::Presenters::Settings
  class Table < Query
    attr_reader :headings

    def initialize(headings)
      super()
      @headings = Hash[headings.zip(headings)].with_indifferent_access
    end

    def override_heading(*args, &block)
      if block_given?
        @headings.each do |key, val|
          res = yield val
          @headings[key] = res if res
        end
      else
        col, label = args
        @headings[col] = label
      end
    end

    def format(column, &block)
      @settings[:formatters] ||= {}
      @settings[:formatters][column] = block
    end

    def formatters
      (@settings[:formatters] || {})
    end
  end
end