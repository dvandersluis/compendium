require 'spec_helper'
require 'compendium/count_query'

class SingleCounter
  def count
    1792
  end
end

class MultipleCounter
  def count
    { 1 => 123, 2 => 456, 3 => 789 }
  end
end

describe Compendium::CountQuery do
  subject { described_class.new(:counted_query, { count: true }, -> * { @counter }) }

  describe "#run" do
    it "should call count on the proc result" do
      @counter = SingleCounter.new
      @counter.should_receive(:count).and_return(1234)
      subject.run(nil, self)
    end

    it "should return the count" do
      @counter = SingleCounter.new
      subject.run(nil, self).should == [1792]
    end

    it "should return a hash if given" do
      @counter = MultipleCounter.new
      subject.run(nil, self).should == { 1 => 123, 2 => 456, 3 => 789 }
    end

    it "should raise an error if the proc does not respond to count" do
      @counter = Class.new
      expect { subject.run(nil, self) }.to raise_error Compendium::InvalidCommand
    end
  end
end