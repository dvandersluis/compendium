require 'compendium/query'

describe Compendium::Query do
  describe "#initialize" do
    let(:options) { double("Options") }
    let(:proc) { double("Proc") }

    context "when supplying a report" do
      let(:r) { Compendium::Report.new }
      subject { described_class.new(r, :test, options, proc)}

      its(:report) { should == r }
      its(:name) { should == :test }
      its(:options) { should == options }
      its(:proc) { should == proc }
    end

    context "when not supplying a report" do
      subject { described_class.new(:test, options, proc)}

      its(:report) { should be_nil }
      its(:name) { should == :test }
      its(:options) { should == options }
      its(:proc) { should == proc }
    end
  end

  describe "#run" do
    let(:query) { described_class.new(:test, {}, -> * { [1, 2, 3] }) }
    before { query.stub(:fetch_results) { |c| c } }

    it "should return the result of the query" do
      query.run(nil).should == [1, 2, 3]
    end

    it "should mark the query as having ran" do
      query.run(nil)
      query.should have_run
    end

    it "should not affect any cloned queries" do
      q2 = query.clone
      query.run(nil)
      q2.should_not have_run
    end

    it "should return an empty result set if running an query with no proc" do
      query = described_class.new(:blank, {}, nil)
      query.run(nil).should be_empty
    end

    context 'through queries' do
      let(:parent_query1) { described_class.new(:parent1, {}, -> * { }) }
      let(:parent_query2) { described_class.new(:parent2, {}, -> * { }) }
      let(:parent_query3) { described_class.new(:parent3, {}, -> * { [[1, 2, 3]] }) }

      subject { described_class.new(:sub, {}, -> records { records.first }) }

      before do
        subject.stub(:get_through_query).with(:parent1).and_return(parent_query1)
        subject.stub(:get_through_query).with(:parent2).and_return(parent_query2)
        subject.stub(:get_through_query).with(:parent3).and_return(parent_query3)
        described_class.any_instance.stub(:execute_query) { |cmd| cmd }
      end

      it "should not try to run a through query if the parent query has no results" do
        subject.through = :parent1

        expect { subject.run(nil) }.to_not raise_error
        subject.results.should be_empty
      end

      it "should not try to run a through query with multiple parents all of which have no results" do
        subject.through = [:parent1, :parent2]

        expect { subject.run(nil) }.to_not raise_error
        subject.results.should be_empty
      end

      it "should allow non blank queries" do
        subject.through = :parent3
        subject.run(nil)
        subject.results.should == [1, 2, 3]
      end
    end
  end

  describe "#nil?" do
    it "should return true if the query's proc is nil" do
      Compendium::Query.new(:test, {}, nil).should be_nil
    end

    it "should return false if the query's proc is not nil" do
      Compendium::Query.new(:test, {}, ->{}).should_not be_nil
    end
  end
end
