require 'compendium/through_query'

describe Compendium::ThroughQuery do
  describe "#initialize" do
    let(:options) { double("Options") }
    let(:proc) { double("Proc") }
    let(:through) { double("Query") }

    context "when supplying a report" do
      let(:r) { Compendium::Report.new }
      subject { described_class.new(r, :test, through, options, proc)}

      its(:report) { should == r }
      its(:name) { should == :test }
      its(:through) { should == through }
      its(:options) { should == options }
      its(:proc) { should == proc }
    end

    context "when not supplying a report" do
      subject { described_class.new(:test, through, options, proc)}

      its(:report) { should be_nil }
      its(:name) { should == :test }
      its(:through) { should == through }
      its(:options) { should == options }
      its(:proc) { should == proc }
    end
  end

  describe "#run" do
    let(:parent1) { Compendium::Query.new(:parent1, {}, -> * { }) }
    let(:parent2) { Compendium::Query.new(:parent2, {}, -> * { }) }
    let(:parent3) { Compendium::Query.new(:parent3, {}, -> * { [[1, 2, 3]] }) }

    before { parent3.stub(:execute_query) { |cmd| cmd } }

    it "should pass along the params if the proc collects it" do
      params = { one: 1, two: 2 }
      q = described_class.new(:through, parent3, {}, -> r, params { params })
      q.run(params).should == params
    end

    it "should pass along the params if the proc has a splat argument" do
      params = { one: 1, two: 2 }
      q = described_class.new(:through, parent3, {}, -> *args { args })
      q.run(params).should == [[[1, 2, 3]], params.with_indifferent_access]
    end

    it "should not pass along the params if the proc doesn't collects it" do
      params = { one: 1, two: 2 }
      q = described_class.new(:through, parent3, {}, -> r { r })
      q.run(params).should == [[1, 2, 3]]
    end

    it "should not affect its parent query" do
      q = described_class.new(:through, parent3, {}, -> r { r.map!{ |i| i * 2 } })
      q.run(nil).should == [[1, 2, 3, 1, 2, 3]]
      parent3.results.should == [[1, 2, 3]]
    end

    context "with a single parent" do
      subject { described_class.new(:sub, parent1, {}, -> r { r.first }) }

      it "should not try to run a through query if the parent query has no results" do
        expect { subject.run(nil) }.to_not raise_error
        subject.results.should be_empty
      end
    end

    context "with multiple parents" do
      subject { described_class.new(:sub, [parent1, parent2], {}, -> r { r.first }) }

      it "should not try to run a through query with multiple parents all of which have no results" do
        expect { subject.run(nil) }.to_not raise_error
        subject.results.should be_empty
      end

      it "should allow non blank queries" do
        subject.through = parent3
        subject.run(nil)
        subject.results.should == [1, 2, 3]
      end
    end

    context "when the through option is an actual query" do
      subject { described_class.new(:sub, parent3, {}, -> r { r.first }) }

      before { subject.run(nil) }

      its(:through) { should == parent3 }
      its(:results) { should == [1, 2, 3] }
    end
  end
end
