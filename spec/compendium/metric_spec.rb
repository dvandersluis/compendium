require 'compendium/metric'

class MetricContext
  def calculate(data)
    data.first.first
  end
end

describe Compendium::Metric do
  let(:ctx) { MetricContext.new }
  let(:data) { [[1, 2, 3], [4, 5, 6]] }

  subject { described_class.new(:test_metric, :query, nil) }

  describe "#run" do
    it "should delegate the command to the context when the command is a symbol" do
      subject.command = :calculate
      expect(subject.run(ctx, data)).to eq(1)
    end

    it "should call the command when it is a proc" do
      subject.command = -> d { d.flatten.inject(:+) }
      expect(subject.run(ctx, data)).to eq(21)
    end

    it "should allow procs that refer back to the context" do
      subject.command = -> d { calculate(d) * 2 }
      expect(subject.run(ctx, data)).to eq(2)
    end

    context "when an if proc is given" do
      before { subject.command = -> * { 100 } }

      it "should calculate the metric if the proc evaluates to true" do
        subject.options[:if] = ->{ true }
        expect(subject.run(ctx, data)).to eq(100)
      end

      it "should not calculate the metric if the proc evaluates to false" do
        subject.options[:if] = ->{ false }
        expect(subject.run(ctx, data)).to be_nil
      end

      it "should clear the result if the proc evaluates to false" do
        subject.options[:if] = ->{ false }
        subject.result = 123
        subject.run(ctx, data)
        expect(subject.result).to be_nil
      end
    end

    context "when an unless proc is given" do
      before { subject.command = -> * { 100 } }

      it "should calculate the metric if the proc evaluates to false" do
        subject.options[:unless] = ->{ false }
        expect(subject.run(ctx, data)).to eq(100)
      end

      it "should not calculate the metric if the proc evaluates to true" do
        subject.options[:unless] = ->{ true }
        expect(subject.run(ctx, data)).to be_nil
      end

      it "should clear the result if the proc evaluates to false" do
        subject.options[:unless] = ->{ true }
        subject.result = 123
        subject.run(ctx, data)
        expect(subject.result).to be_nil
      end
    end
  end

  describe "#ran?" do
    it "should return true if there are any results" do
      allow(subject).to receive_messages(result: 123)
      expect(subject).to have_ran
    end

    it "should return false if there are no results" do
      expect(subject).not_to have_ran
    end
  end
end