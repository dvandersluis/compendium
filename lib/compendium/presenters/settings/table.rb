require 'compendium/presenters/settings/query'

module Compendium
  module Presenters
    module Settings
      class Table < Query
        attr_reader :headings

        def initialize(*)
          super

          @headings = {}

          # Set default values for settings
          number_format       '%0.2f'
          table_class         'results'
          header_class        'headings'
          row_class           'data'
          totals_class        'totals'
          skipped_total_cols  []
        end

        def set_headings(headings)
          headings.map!(&:to_sym)
          @headings = Hash[headings.zip(headings)].with_indifferent_access
        end

        def override_heading(*args)
          if block_given?
            @headings.each do |key, val|
              res = yield val.to_s
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

        def skip_total_for(*cols)
          @settings[:skipped_total_cols].concat(cols.map(&:to_sym))
        end
      end
    end
  end
end
