require 'spec_helper'
require 'compendium/sum_query'
require 'compendium/report'

class SingleSummer
  def sum(col)
    1792
  end
end

class MultipleSummer
  def order(*)
    @order = true
    self
  end

  def reverse_order
    @reverse = true
    self
  end

  def sum(col)
    results = { 1 => 340, 2 => 204, 3 => 983 }

    if @order
      results = results.sort_by{ |r| r[1] }
      results.reverse! if @reverse
      results = Hash[results]
    end

    results
  end
end

describe Compendium::SumQuery do
  subject { described_class.new(:counted_query, :col, { sum: :col }, -> * { @counter }) }

  it 'should have a default order' do
    subject.options[:order].should == 'SUM(col)'
    subject.options[:reverse].should == true
  end

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

    context 'when given a hash' do
      before { @counter = MultipleSummer.new }

      it "should return a hash if given" do
        subject.run(nil, self).should == { 3 => 983, 1 => 340, 2 => 204 }
      end

      it 'should be ordered in descending order' do
        subject.run(nil, self).keys.should == [3, 1, 2]
      end

      it 'should use the given options' do
        subject.options[:reverse] = false
        subject.run(nil, self).keys.should == [2, 1, 3]
      end
    end

    it "should raise an error if the proc does not respond to sum" do
      @counter = Class.new
      expect { subject.run(nil, self) }.to raise_error Compendium::InvalidCommand
    end
  end
end