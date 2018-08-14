require 'compendium/presenters/table'

RSpec.describe Compendium::Presenters::Table do
  let(:template) { double('Template') }
  let(:results) { double('Results', records: [{ one: 1, two: 2 }, { one: 3, two: 4 }], keys: [:one, :two]) }
  let(:query) { double('Query', results: results, options: {}, table_settings: nil) }
  let(:table) { described_class.new(template, query) }

  context 'render' do
    before do
      allow(template).to receive(:content_tag) { |element, *, &block| block.nil? ? element : table.instance_exec(&block) }
      allow(I18n).to receive(:t) { |key| key }
    end

    it 'uses the table class given in settings' do
      table.settings.table_class 'report_table'

      expect(template).to receive(:content_tag).with(:table, class: 'report_table')
      table.render
    end

    it 'uses the default table class if not specified' do
      expect(template).to receive(:content_tag).with(:table, class: 'results')
      table.render
    end

    it 'builds the heading row' do
      expect(template).to receive(:content_tag).with(:tr, class: 'headings')
      expect(template).to receive(:content_tag).with(:th, :one)
      expect(template).to receive(:content_tag).with(:th, :two)
      table.render
    end

    it 'uses the overridden heading class if given' do
      table.settings.header_class 'report_header'

      expect(template).to receive(:content_tag).with(:tr, class: 'report_header')
      table.render
    end

    it 'builds data rows' do
      expect(template).to receive(:content_tag).with(:tr, class: 'data').twice
      table.render
    end

    it 'uses the overridden row class if given' do
      table.settings.row_class 'report_row'

      expect(template).to receive(:content_tag).with(:tr, class: 'report_row').twice
      table.render
    end

    it 'adds a totals row if the query has totals: true set' do
      query.options[:totals] = true

      expect(template).to receive(:content_tag).with(:tr, class: 'totals')
      table.render
    end

    it 'does not add a totals row if the query has totals: false set' do
      query.options[:totals] = false

      expect(template).to_not receive(:content_tag).with(:tr, class: 'totals')
      table.render
    end

    it 'does not add a totals row if the query does not have :totals set' do
      query.options.delete(:totals)

      expect(template).to_not receive(:content_tag).with(:tr, class: 'totals')
      table.render
    end

    it 'uses the totals class if that setting is overridden' do
      query.options[:totals] = true
      table.settings.totals_class 'report_totals'

      expect(template).to receive(:content_tag).with(:tr, class: 'report_totals')
      table.render
    end
  end
end
