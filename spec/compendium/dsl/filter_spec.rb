require 'spec_helper'
require 'compendium'
require 'compendium/dsl'

describe Compendium::DSL::Filter do
  subject do
    Class.new do
      extend Compendium::DSL
    end
  end

  describe '#filter' do
    let(:filter_proc) { -> { :filter } }

    it 'should add a filter to the given query' do
      subject.query :test
      subject.filter :test, &filter_proc
      expect(subject.queries[:test].filters).to include filter_proc
    end

    it 'should raise an error if there is no query of the given name' do
      expect { subject.filter :test, &filter_proc }.to raise_error(ArgumentError, 'query test is not defined')
    end

    it 'should allow multiple filters to be defined for the same query' do
      subject.query :test
      subject.filter :test, &filter_proc
      subject.filter :test, &-> { :another_filter }
      expect(subject.queries[:test].filters.count).to eq(2)
    end

    it 'should allow a filter to be applied to multiple queries at once' do
      subject.query :query1
      subject.query :query2
      subject.filter :query1, :query2, &filter_proc
      expect(subject.queries[:query1].filters).to include filter_proc
      expect(subject.queries[:query2].filters).to include filter_proc
    end
  end
end
