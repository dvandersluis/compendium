require 'csv'

module Compendium
  module Presenters
    class CSV < Table
      def initialize(object, &block)
        super(nil, object, &block)
      end

      def render
        ::CSV.generate do |csv|
          csv << headings.map { |_, val| formatted_heading(val) }

          records.each do |row|
            csv << row.map { |key, val| formatted_value(key, val) }
          end

          if totals_row?
            totals[totals.keys.first] = translate(:total)
            csv << totals.map do |key, val|
              formatted_value(key, val) unless settings.skipped_total_cols.include?(key.to_sym)
            end
          end
        end
      end

    private

      def settings_class
        Compendium::Presenters::Settings::Table
      end
    end
  end
end
