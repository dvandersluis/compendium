require 'spec_helper'
require 'compendium/presenters/table'

describe Compendium::Presenters::Settings::Table do
  let(:results) { double('Results', records: [{ one: 1, two: 2 }, { one: 3, two: 4 }], keys: [:one, :two]) }
  let(:query) { double('Query', results: results, options: {}, table_settings: nil) }
  let(:table) { Compendium::Presenters::Table.new(nil, query) }

  subject { table.settings }

  context 'default settings' do
    its(:number_format) { should == '%0.2f' }
    its(:table_class) { should == 'results' }
    its(:header_class) { should == 'headings' }
    its(:row_class) { should == 'data' }
    its(:totals_class) { should == 'totals' }
    its(:display_nil_as) { should be_nil }
    its(:skipped_total_cols) { should be_empty }
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

    its(:number_format) { should == '%0.1f' }
    its(:table_class) { should == 'report_table' }
    its(:header_class) { should == 'report_heading' }
    its(:display_nil_as) { should == 'N/A' }
  end

  describe '#update' do
    it 'should override previous settings' do
      subject.update do |s|
        s.number_format '%0.3f'
      end

      subject.number_format.should == '%0.3f'
    end
  end

  describe '#skip_total_for' do
    it 'should add columns to the setting' do
      subject.skip_total_for :foo, :bar
      subject.skipped_total_cols.should == [:foo, :bar]
    end

    it 'should be callable multiple times' do
      subject.skip_total_for :foo, :bar
      subject.skip_total_for :quux
      subject.skipped_total_cols.should == [:foo, :bar, :quux]
    end

    it 'should not care about type' do
      subject.skip_total_for 'foo'
      subject.skipped_total_cols.should == [:foo]
    end
  end
end
