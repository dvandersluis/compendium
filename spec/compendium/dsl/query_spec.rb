require 'spec_helper'
require 'compendium/dsl'

describe Compendium::DSL::Query do
  let(:proc1) { -> { :proc1 } }
  let(:proc2) { -> { :proc2 } }
  let(:report_class) do
    proc1 = proc1

    Class.new(Compendium::Report) do
      query :test, &proc1
    end
  end

  subject { report_class }

  describe '#query' do
    specify { expect(subject.queries).to include :test }

    it 'should relate the new query back to the report instance' do
      r = subject.new
      expect(r.test.report).to eq(r)
    end

    it 'should relate a query to the report class' do
      expect(subject.test.report).to eq(subject)
    end

    context 'when the query was previously defined' do
      before { subject.query :test_query }

      it 'should allow previously defined queries to be redefined by name' do
        subject.test_query foo: :bar
        expect(subject.queries[:test_query].options).to eq(foo: :bar)
      end

      it 'should allow previously defined queries to be accessed by name' do
        expect(subject.test_query).to eq(subject.queries[:test_query])
      end
    end

    context 'when overriding an existing query' do
      before do
        subject.query :test, &proc2
        subject.query :another_test, count: true
      end

      it 'should delete the existing query' do
        expect(subject.queries.count).to eq(2)
      end

      it 'should only have one query with each name' do
        expect(subject.queries.map(&:name)).to match_array([:test, :another_test])
      end

      it 'should use the new proc' do
        expect(subject.test.proc).to eq(proc2)
      end

      it 'should not allow replacing a query with a different type' do
        expect { subject.query :test, count: true }.to raise_error(Compendium::Queries::CannotRedefineType)
        expect(subject.test).to be_instance_of Compendium::Queries::Query
      end

      it 'should allow replacing a query with the same type' do
        subject.query :another_test, count: true, &proc2
        expect(subject.another_test.proc).to eq(proc2)
        expect(subject.another_test).to be_instance_of Compendium::Queries::Count
      end
    end

    context 'when given a through option' do
      before { report_class.query :through, through: :test }
      subject { report_class.queries[:through] }

      specify { is_expected.to be_a Compendium::Queries::Through }
      specify { expect(subject.through).to eq([:test]) }
    end

    context 'when given a collection option' do
      subject { report_class.queries[:collection] }

      context 'that is an enumerable' do
        before { report_class.query :collection, collection: [] }

        it { is_expected.to be_a Compendium::Queries::Collection }
      end

      context 'that is a symbol' do
        let(:query) { double('Query') }

        before do
          allow_any_instance_of(Compendium::Queries::Query).to receive(:get_associated_query).with(:query).and_return(query)
          report_class.query :collection, collection: :query
        end

        specify { expect(subject.collection).to eq(:query) }
      end

      context 'that is a query' do
        let(:query) { Compendium::Queries::Query.new(:query, {}, -> {}) }
        before { report_class.query :collection, collection: query }

        specify { expect(subject.collection).to eq(query) }
      end
    end

    context 'when given a count option' do
      subject { report_class.queries[:counted] }

      context 'set to true' do
        before { report_class.query :counted, count: true }
        it { is_expected.to be_a Compendium::Queries::Count }
      end

      context 'set to false' do
        before { report_class.query :counted, count: false }
        it { is_expected.to be_a Compendium::Queries::Query }
        it { is_expected.not_to be_a Compendium::Queries::Count }
      end
    end

    context 'when given a sum option' do
      subject { report_class.queries[:summed] }

      context 'set to a truthy value' do
        before { report_class.query :summed, sum: :assoc_count }

        it { is_expected.to be_a Compendium::Queries::Sum }
        specify { expect(subject.column).to eq(:assoc_count) }
      end

      context 'set to false' do
        before { report_class.query :summed, sum: false }
        it { is_expected.to be_a Compendium::Queries::Query }
        it { is_expected.not_to be_a Compendium::Queries::Sum }
      end
    end
  end

  describe '#chart' do
    before { subject.chart(:chart) }
    specify { expect(subject.queries).to include :chart }
  end

  describe '#data' do
    before { subject.data(:data) }
    specify { expect(subject.queries).to include :data }
  end
end
