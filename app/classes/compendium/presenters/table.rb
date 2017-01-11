module Compendium::Presenters
  class Table < Query
    attr_reader :records, :totals, :settings

    def initialize(*)
      super

      @records = results.records
      @totals = @records.pop if has_totals_row?

      @settings = settings_class.new(results.keys)
      yield @settings if block_given?
    end

    def render
      content_tag(:table, class: @settings.table_class) do
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

    def headings
      @settings.headings
    end

    def has_totals_row?
      query.options.fetch(:totals, false)
    end

    def build_data_row(row)
      build_row(row, @settings.row_class) { |key, val| formatted_value(key, val) }
    end

    def build_heading_row
      build_row(headings, @settings.header_class, :th) { |_, val| formatted_heading(val) }
    end

    def build_totals_row
      totals[totals.keys.first] = t(:total)
      build_row(totals, @settings.totals_class, :th) { |key, val| formatted_value(key, val) }
    end

    def build_row(row, row_class, cell_type = :td)
      content_tag(:tr, class: row_class) do
        out = ActiveSupport::SafeBuffer.new

        row.each.with_index do |(key, val), i|
          val = yield key, val, i if block_given?
          out << content_tag(cell_type, val)
        end

        out
      end
    end

    def formatted_heading(v)
      v.is_a?(Symbol) ? translate(v) : v
    end

    def formatted_value(k, v)
      if @settings.formatters[k]
        @settings.formatters[k].call(v)
      else
        if v.numeric?
          if v.zero? && @settings.display_zero_as?
            @settings.display_zero_as
          else
            sprintf(@settings.number_format, v)
          end
        elsif v.nil?
          @settings.display_nil_as
        end
      end || v
    end

    def translate(v, opts = {})
      opts.reverse_merge!(scope: settings.i18n_scope) if settings.i18n_scope?
      opts[:default] = -> * { I18n.t(v, scope: 'compendium') }
      I18n.t(v, opts)
    end
  end
end
