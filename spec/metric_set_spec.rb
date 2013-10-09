require 'compendium/metric_set'

describe Compendium::MetricSet do
  let(:metric1) { double("Metric", name: :one) }
  let(:metric2) { double("Metric", name: :two) }

  subject { described_class.new }

  it { should be_empty }

  it "should accept new items" do
    subject << metric1
    subject << metric2
    subject.size.should == 2
  end

  describe "#[]" do
    before { subject << metric1 }

    it "should retrieve metrics by name" do
      subject[:one].should == metric1
    end

    it "should return nil when given a name that doesn't match a metric" do
      subject[:foo].should be_nil
    end
  end

  describe "#except" do
    before do
      subject << metric1
      subject << metric2
    end

    it "should return all metrics except for the named ones" do
      subject.except(:one).should == [metric2]
    end

    it "should allow multiple names to be specified" do
      subject.except(:one, :two).should == []
    end

    it "should return another MetricSet" do
      subject.except(:one).should be_a Compendium::MetricSet
    end
  end

  describe "#==" do
    it "should be equal to an empty array when it has no members" do
      subject.should == []
    end

    it "should be equal to an array of its members" do
      subject << metric1
      subject << metric2
      (subject == [metric1, metric2]).should be_true
    end
  end
end