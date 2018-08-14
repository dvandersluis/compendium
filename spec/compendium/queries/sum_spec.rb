require 'compendium/queries/sum'
require 'compendium/report'

class SingleSummer
  def sum(*)
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

  def sum(*)
    results = { 1 => 340, 2 => 204, 3 => 983 }

    if @order
      results = results.sort_by { |r| r[1] }
      results.reverse! if @reverse
      results = Hash[results]
    end

    results
  end
end

RSpec.describe Compendium::Queries::Sum do
  subject { described_class.new(:counted_query, :col, { sum: :col }, -> (*) { summer }) }

  it 'has a default order' do
    expect(subject.options[:order]).to eq('SUM(col)')
    expect(subject.options[:reverse]).to eq(true)
  end

  describe '#run' do
    let(:summer) { SingleSummer.new }

    it 'calls sum on the proc result' do
      expect(summer).to receive(:sum).with(:col).and_return(1234)
      subject.run(nil, self)
    end

    it 'returns the sum' do
      expect(subject.run(nil, self)).to eq([1792])
    end

    context 'when given a hash' do
      let(:summer) { MultipleSummer.new }

      it 'returns a hash if given' do
        expect(subject.run(nil, self)).to eq(3 => 983, 1 => 340, 2 => 204)
      end

      it 'is ordered in descending order' do
        expect(subject.run(nil, self).keys).to eq([3, 1, 2])
      end

      it 'uses the given options' do
        subject.options[:reverse] = false
        expect(subject.run(nil, self).keys).to eq([2, 1, 3])
      end
    end

    context 'when the proc does not respond to sum' do
      let(:summer) { Class.new }

      it 'raises an error if the proc does not respond to sum' do
        expect { subject.run(nil, self) }.to raise_error Compendium::Queries::InvalidCommand
      end
    end
  end
end
