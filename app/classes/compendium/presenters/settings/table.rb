module Compendium::Presenters::Settings
  class Table < Query
    attr_reader :headings

    def initialize(headings)
      super()
      @headings = Hash[headings.zip(headings)].with_indifferent_access
    end

    def override_heading(col, label)
      @headings[col] = label
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