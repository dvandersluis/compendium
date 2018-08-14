require 'compendium'
require 'compendium/dsl'

RSpec.describe Compendium::DSL::Table do
  subject do
    Class.new do
      extend Compendium::DSL
    end
  end

  describe '#table' do
    let(:table_proc) { -> { display_nil_as 'na' } }

    it 'adds table settings to the given query' do
      subject.query :test
      subject.table :test, &table_proc
      expect(subject.queries[:test].table_settings).to eq(table_proc)
    end

    it 'raises an error if there is no query of the given name' do
      expect { subject.table :test, &table_proc }.to raise_error(ArgumentError, 'query test is not defined')
    end

    it 'allows table settings to be applied to multiple queries at once' do
      subject.query :query1
      subject.query :query2
      subject.table :query1, :query2, &table_proc
      expect(subject.queries[:query1].table_settings).to eq(table_proc)
      expect(subject.queries[:query2].table_settings).to eq(table_proc)
    end
  end
end
