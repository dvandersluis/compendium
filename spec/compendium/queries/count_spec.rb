require 'spec_helper'
require 'compendium'
require 'compendium/queries/count'

class SingleCounter
  def count
    1792
  end
end

class MultipleCounter
  def order(*)
    @order = true
    self
  end

  def reverse_order
    @reverse = true
    self
  end

  def count
    results = { 1 => 340, 2 => 204, 3 => 983 }

    if @order
      results = results.sort_by{ |r| r[1] }
      results.reverse! if @reverse
      results = Hash[results]
    end

    results
  end
end

describe Compendium::Queries::Count do
  subject { described_class.new(:counted_query, { count: true }, -> * { @counter }) }

  it 'should have a default order' do
    expect(subject.options[:order]).to eq('COUNT(*)')
    expect(subject.options[:reverse]).to eq(true)
  end

  describe "#run" do
    it "should call count on the proc result" do
      @counter = SingleCounter.new
      expect(@counter).to receive(:count).and_return(1234)
      subject.run(nil, self)
    end

    it "should return the count" do
      @counter = SingleCounter.new
      expect(subject.run(nil, self)).to eq([1792])
    end

    context 'when given a hash' do
      before { @counter = MultipleCounter.new }

      it "should return a hash" do
        expect(subject.run(nil, self)).to eq({ 3 => 983, 1 => 340, 2 => 204 })
      end

      it 'should be ordered in descending order' do
        expect(subject.run(nil, self).keys).to eq([3, 1, 2])
      end

      it 'should use the given options' do
        subject.options[:reverse] = false
        expect(subject.run(nil, self).keys).to eq([2, 1, 3])
      end
    end

    it "should raise an error if the proc does not respond to count" do
      @counter = Class.new
      expect { subject.run(nil, self) }.to raise_error Compendium::Queries::InvalidCommand
    end
  end
end
