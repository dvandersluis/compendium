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
      subject.run(ctx, data).should == 1
    end

    it "should call the command when it is a proc" do
      subject.command = -> d { d.flatten.inject(:+) }
      subject.run(ctx, data).should == 21
    end

    it "should allow procs that refer back to the context" do
      subject.command = -> d { calculate(d) * 2 }
      subject.run(ctx, data).should == 2
    end

    context "when an if proc is given" do
      before { subject.command = -> * { 100 } }

      it "should calculate the metric if the proc evaluates to true" do
        subject.options[:if] = ->{ true }
        subject.run(ctx, data).should == 100
      end

      it "should not calculate the metric if the proc evaluates to false" do
        subject.options[:if] = ->{ false }
        subject.run(ctx, data).should be_nil
      end

      it "should clear the result if the proc evaluates to false" do
        subject.options[:if] = ->{ false }
        subject.result = 123
        subject.run(ctx, data)
        subject.result.should be_nil
      end
    end

    context "when an unless proc is given" do
      before { subject.command = -> * { 100 } }

      it "should calculate the metric if the proc evaluates to false" do
        subject.options[:unless] = ->{ false }
        subject.run(ctx, data).should == 100
      end

      it "should not calculate the metric if the proc evaluates to true" do
        subject.options[:unless] = ->{ true }
        subject.run(ctx, data).should be_nil
      end

      it "should clear the result if the proc evaluates to false" do
        subject.options[:unless] = ->{ true }
        subject.result = 123
        subject.run(ctx, data)
        subject.result.should be_nil
      end
    end
  end

  describe "#ran?" do
    it "should return true if there are any results" do
      subject.stub(result: 123)
      subject.should have_ran
    end

    it "should return false if there are no results" do
      subject.should_not have_ran
    end
  end
end