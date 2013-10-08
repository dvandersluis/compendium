module Compendium::Presenters
  class Table < Query
    attr_reader :records, :totals

    def initialize(*)
      super

      @records = results.records
      @totals = @records.pop if has_totals_row?
    end

    def render
      content_tag(:table, class: 'results') do
        table = ActiveSupport::SafeBuffer.new
        table << content_tag(:thead, build_heading_row)
        table << content_tag(:tbody) do
          tbody = ActiveSupport::SafeBuffer.new
          records.each { |row| tbody << build_data_row(row) }
          tbody
        end
        table << content_tag(:tfoot, build_totals_row) if has_totals_row?
        table
      end
    end

  private

    def results
      query.results
    end

    def headings
      @settings.headings
    end

    def has_totals_row?
      query.options.fetch(:totals, false)
    end

    def build_data_row(row)
      build_row(row, 'data') { |key, val| formatted_value(key, val) }
    end

    def build_heading_row
      build_row(headings, 'headings', :th) { |key, val| t(val) }
    end

    def build_totals_row
      totals[totals.keys.first] = t(:total)
      build_row(totals, 'totals', :th) { |key, val| formatted_value(key, val) }
    end

    def build_row(row, row_class, cell_type = :td)
      content_tag('tr', class: row_class) do
        out = ActiveSupport::SafeBuffer.new

        row.each.with_index do |(key, val), i|
          val = yield key, val, i if block_given?
          out << content_tag(cell_type, val)
        end

        out
      end
    end

    def formatted_value(k, v)
      if @settings.formatters[k]
        @settings.formatters[k].call(v)
      else
        if v.numeric?
          if v.zero? and @settings.display_zero_as?
            @settings.display_zero_as
          else
            sprintf(@settings.number_format || '%0.2f', v)
          end
        elsif v.nil?
          @settings.display_nil_as
        end
      end || v
    end
  end
end