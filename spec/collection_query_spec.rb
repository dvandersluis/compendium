require 'spec_helper'
require 'compendium/collection_query'

describe Compendium::CollectionQuery do
  let(:collection) { { one: 1, two: 2, three: 3 } }
  subject { described_class.new(:collection_query, { collection: collection }, -> _, key, item { [item * 2] }) }

  before { Compendium::Query.any_instance.stub(:execute_query) { |cmd| cmd } }

  describe "#run" do
    context do
      before { subject.run(nil) }

      its(:results) { should be_a Compendium::ResultSet }
      its(:results) { should == { one: [2], two: [4], three: [6] } }

      context "when given an array instead of a hash" do
        let(:collection) { [1, 2, 3] }

        its(:results) { should be_a Compendium::ResultSet }
        its(:results) { should == { 1 => [2], 2 => [4], 3 => [6] } }
      end
    end

    it "should not collect empty results" do
      subject.proc = -> _, key, item { [item] if item > 2 }
      subject.run(nil)
      subject.results.should == { three: [3] }
    end

    context "when given another query" do
      let(:q) { Compendium::Query.new(:q, {}, -> * { { one: 1, two: 2, three: 3 } }) }
      subject { described_class.new(:collection, { collection: q }, -> _, key, item { [ item * 2 ] }) }

      before { subject.run(nil) if example.metadata.fetch(:run_query, true) }

      its(:results) { should == { one: [2], two: [4], three: [6] } }

      it "should not re-run the query if it has already ran", run_query: false do
        q.run(nil)
        q.should_not_receive(:run)
        subject.run(nil)
      end
    end

    context 'when given a proc' do
      let(:proc) { -> * { [1, 2, 3] } }
      subject { described_class.new(:collection, { collection: proc }, -> _, key, item { [ item * 2 ] }) }

      it 'should use the collection from the proc' do
        subject.run(nil)
        subject.results.should == { 1 => [2], 2 => [4], 3 => [6] }
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
