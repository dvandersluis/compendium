require 'spec_helper'
require 'compendium/collection_query'

describe Compendium::CollectionQuery do
  let(:collection) { { one: 1, two: 2, three: 3 } }
  subject { described_class.new(:collection_query, { collection: collection }, -> _, key, item { [item * 2] }) }

  before { allow_any_instance_of(Compendium::Query).to receive(:execute_query) { |instance, cmd| cmd } }

  describe "#run" do
    context do
      before { subject.run(nil) }

      specify { expect(subject.results).to be_a Compendium::ResultSet }
      specify { expect(subject.results).to eq({ one: [2], two: [4], three: [6] }) }

      context "when given an array instead of a hash" do
        let(:collection) { [1, 2, 3] }

        specify { expect(subject.results).to be_a Compendium::ResultSet }
        specify { expect(subject.results).to eq({ 1 => [2], 2 => [4], 3 => [6] }) }
      end
    end

    it "should not collect empty results" do
      subject.proc = -> _, key, item { [item] if item > 2 }
      subject.run(nil)
      expect(subject.results).to eq({ three: [3] })
    end

    context "when given another query" do
      let(:q) { Compendium::Query.new(:q, {}, -> * { { one: 1, two: 2, three: 3 } }) }
      subject { described_class.new(:collection, { collection: q }, -> _, key, item { [ item * 2 ] }) }

      before { subject.run(nil) if RSpec.current_example.metadata.fetch(:run_query, true) }

      specify { expect(subject.results).to eq({ one: [2], two: [4], three: [6] }) }

      it "should not re-run the query if it has already ran", run_query: false do
        q.run(nil)
        expect(q).not_to receive(:run)
        subject.run(nil)
      end
    end

    context 'when given a proc' do
      let(:proc) { -> * { [1, 2, 3] } }
      subject { described_class.new(:collection, { collection: proc }, -> _, key, item { [ item * 2 ] }) }

      it 'should use the collection from the proc' do
        subject.run(nil)
        expect(subject.results).to eq({ 1 => [2], 2 => [4], 3 => [6] })
      end

      context do
        let(:proc) { -> * { raise ArgumentError } }
        it 'should not run the proc until runtime' do
          expect { subject }.to_not raise_error
        end
      end
    end
  end
end
