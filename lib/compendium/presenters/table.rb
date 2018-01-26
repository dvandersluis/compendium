require 'compendium/presenters/query'

module Compendium
  module Presenters
    class Table < Query
      attr_reader :records, :totals, :settings

      def initialize(*)
        super

        @records = results.records

        @settings = settings_class.new(query)
        @settings.set_headings(results.keys)
        @settings.update(&query.table_settings) if query.table_settings
        yield @settings if block_given?

        setup_totals if totals_row?
      end

      def render
        content_tag(:table, class: @settings.table_class) do
          table = ActiveSupport::SafeBuffer.new
          table << content_tag(:thead, build_row(headings, settings.header_class, :th, &heading_proc))
          table << content_tag(:tbody) do
            tbody = ActiveSupport::SafeBuffer.new
            records.each { |row| tbody << build_row(row, settings.row_class, &data_proc) }
            tbody
          end
          table << content_tag(:tfoot, build_row(totals, @settings.totals_class, :th, &totals_proc)) if totals_row?
          table
        end
      end

    private

      def headings
        @settings.headings
      end

      def totals_row?
        query.options.fetch(:totals, false)
      end

      def data_proc
        proc { |key, val| formatted_value(key, val) }
      end

      def heading_proc
        proc { |_, val| formatted_heading(val) }
      end

      def totals_proc
        proc { |key, val| formatted_value(key, val) unless settings.skipped_total_cols.include?(key.to_sym) }
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
        elsif v.numeric?
          if v.zero? && @settings.display_zero_as?
            @settings.display_zero_as
          else
            sprintf(@settings.number_format, v)
          end
        elsif v.nil?
          @settings.display_nil_as
        end || v
      end

      def translate(v, opts = {})
        opts.reverse_merge!(scope: settings.i18n_scope) if settings.i18n_scope?
        opts[:default] = -> (*) { I18n.t(v, scope: 'compendium') }
        I18n.t(v, opts)
      end

      def setup_totals
        @totals = @records.pop
        totals[totals.keys.first] = translate(:total)
      end

      def settings_class
        Settings::Table
      end
    end
  end
end
