require 'spec_helper'
require 'compendium/sum_query'
require 'compendium/report'

class SingleSummer
  def sum(col)
    1792
  end
end

class MultipleSummer
  def sum(col)
    { 1 => 123, 2 => 456, 3 => 789 }
  end
end

describe Compendium::SumQuery do
  subject { described_class.new(:counted_query, :col, { sum: :col }, -> * { @counter }) }

  describe "#run" do
    it "should call sum on the proc result" do
      @counter = SingleSummer.new
      @counter.should_receive(:sum).with(:col).and_return(1234)
      subject.run(nil, self)
    end

    it "should return the sum" do
      @counter = SingleSummer.new
      subject.run(nil, self).should == [1792]
    end

    it "should return a hash if given" do
      @counter = MultipleSummer.new
      subject.run(nil, self).should == { 1 => 123, 2 => 456, 3 => 789 }
    end

    it "should raise an error if the proc does not respond to sum" do
      @counter = Class.new
      expect { subject.run(nil, self) }.to raise_error Compendium::InvalidCommand
    end
  end
end