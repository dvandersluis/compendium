require 'spec_helper'
require 'compendium/presenters/table'

describe Compendium::Presenters::Settings::Table do
  let(:results) { double('Results', records: [{ one: 1, two: 2 }, { one: 3, two: 4 }], keys: [:one, :two]) }
  let(:query) { double('Query', results: results, options: {}, table_settings: nil) }
  let(:table) { Compendium::Presenters::Table.new(nil, query) }

  subject { table.settings }

  context 'default settings' do
    it 'should return default values' do
      expect(subject.number_format).to eq '%0.2f'
      expect(subject.table_class).to eq('results')
      expect(subject.header_class).to eq('headings')
      expect(subject.row_class).to eq('data')
      expect(subject.totals_class).to eq('totals')
      expect(subject.display_nil_as).to be_nil
      expect(subject.skipped_total_cols).to be_empty
    end
  end

  context 'overriding default settings' do
    let(:table) do
      Compendium::Presenters::Table.new(nil, query) do |t|
        t.number_format '%0.1f'
        t.table_class 'report_table'
        t.header_class 'report_heading'
        t.display_nil_as 'N/A'
      end
    end

    it 'should have overriden settings' do
      expect(subject.number_format).to eq('%0.1f')
      expect(subject.table_class).to eq('report_table')
      expect(subject.header_class).to eq('report_heading')
      expect(subject.display_nil_as).to eq('N/A')
    end
  end

  describe '#update' do
    it 'should override previous settings' do
      subject.update do |s|
        s.number_format '%0.3f'
      end

      expect(subject.number_format).to eq('%0.3f')
    end
  end

  describe '#skip_total_for' do
    it 'should add columns to the setting' do
      subject.skip_total_for :foo, :bar
      expect(subject.skipped_total_cols).to eq([:foo, :bar])
    end

    it 'should be callable multiple times' do
      subject.skip_total_for :foo, :bar
      subject.skip_total_for :quux
      expect(subject.skipped_total_cols).to eq(%i(foo bar quux))
    end

    it 'should not care about type' do
      subject.skip_total_for 'foo'
      expect(subject.skipped_total_cols).to eq([:foo])
    end
  end

  describe '#override_heading' do
    it 'should override a given heading' do
      subject.override_heading :one, 'First Column'
      expect(subject.headings).to eq('one' => 'First Column', 'two' => :two)
    end

    it 'should override multiple headings with a block' do
      subject.override_heading do |col|
        col.to_s * 2
      end
      expect(subject.headings).to eq('one' => 'oneone', 'two' => 'twotwo')
    end
  end
end
