require 'compendium/through_query'

describe Compendium::ThroughQuery do
  describe "#initialize" do
    let(:options) { double("Options") }
    let(:proc) { double("Proc") }
    let(:through) { double("Query") }

    context "when supplying a report" do
      let(:r) { Compendium::Report.new }
      subject { described_class.new(r, :test, through, options, proc)}

      specify { expect(subject.report).to eq(r) }
      specify { expect(subject.name).to eq(:test) }
      specify { expect(subject.through).to eq(through) }
      specify { expect(subject.options).to eq(options) }
      specify { expect(subject.proc).to eq(proc) }
    end

    context "when not supplying a report" do
      subject { described_class.new(:test, through, options, proc)}

      specify { expect(subject.report).to be_nil }
      specify { expect(subject.name).to eq(:test) }
      specify { expect(subject.through).to eq(through) }
      specify { expect(subject.options).to eq(options) }
      specify { expect(subject.proc).to eq(proc) }
    end
  end

  describe "#run" do
    let(:parent1) { Compendium::Query.new(:parent1, {}, -> * { }) }
    let(:parent2) { Compendium::Query.new(:parent2, {}, -> * { }) }
    let(:parent3) { Compendium::Query.new(:parent3, {}, -> * { [[1, 2, 3]] }) }

    before { allow(parent3).to receive(:execute_query) { |cmd| cmd } }

    it "should pass along the params if the proc collects it" do
      params = { one: 1, two: 2 }
      q = described_class.new(:through, parent3, {}, -> r, params { params })
      expect(q.run(params)).to eq(params)
    end

    it "should pass along the params if the proc has a splat argument" do
      params = { one: 1, two: 2 }
      q = described_class.new(:through, parent3, {}, -> *args { args })
      expect(q.run(params)).to eq([[[1, 2, 3]], params.with_indifferent_access])
    end

    it "should not pass along the params if the proc doesn't collects it" do
      params = { one: 1, two: 2 }
      q = described_class.new(:through, parent3, {}, -> r { r })
      expect(q.run(params)).to eq([[1, 2, 3]])
    end

    it "should not affect its parent query" do
      q = described_class.new(:through, parent3, {}, -> r { r.map!{ |i| i * 2 } })
      expect(q.run(nil)).to eq([[1, 2, 3, 1, 2, 3]])
      expect(parent3.results).to eq([[1, 2, 3]])
    end

    context "with a single parent" do
      subject { described_class.new(:sub, parent1, {}, -> r { r.first }) }

      it "should not try to run a through query if the parent query has no results" do
        expect { subject.run(nil) }.to_not raise_error
        expect(subject.results).to be_empty
      end
    end

    context "with multiple parents" do
      subject { described_class.new(:sub, [parent1, parent2], {}, -> r { r.first }) }

      it "should not try to run a through query with multiple parents all of which have no results" do
        expect { subject.run(nil) }.to_not raise_error
        expect(subject.results).to be_empty
      end

      it "should allow non blank queries" do
        subject.through = parent3
        subject.run(nil)
        expect(subject.results).to eq([1, 2, 3])
      end
    end

    context "when the through option is an actual query" do
      subject { described_class.new(:sub, parent3, {}, -> r { r.first }) }

      before { subject.run(nil) }

      specify { expect(subject.through).to eq(parent3) }
      specify { expect(subject.results).to eq([1, 2, 3]) }
    end
  end
end
