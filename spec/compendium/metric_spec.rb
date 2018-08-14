require 'compendium/metric'

class MetricContext
  def calculate(data)
    data.first.first
  end
end

RSpec.describe Compendium::Metric do
  let(:ctx) { MetricContext.new }
  let(:data) { [[1, 2, 3], [4, 5, 6]] }

  subject { described_class.new(:test_metric, :query, nil) }

  describe '#run' do
    it 'delegates the command to the context when the command is a symbol' do
      subject.command = :calculate
      expect(subject.run(ctx, data)).to eq(1)
    end

    it 'calls the command when it is a proc' do
      subject.command = -> (d) { d.flatten.inject(:+) }
      expect(subject.run(ctx, data)).to eq(21)
    end

    it 'allows procs that refer back to the context' do
      subject.command = -> (d) { calculate(d) * 2 }
      expect(subject.run(ctx, data)).to eq(2)
    end

    context 'when an if proc is given' do
      before { subject.command = -> (*) { 100 } }

      it 'calculates the metric if the proc evaluates to true' do
        subject.options[:if] = -> { true }
        expect(subject.run(ctx, data)).to eq(100)
      end

      it 'does not calculate the metric if the proc evaluates to false' do
        subject.options[:if] = -> { false }
        expect(subject.run(ctx, data)).to be_nil
      end

      it 'sets the result to nil if the proc evaluates to false' do
        subject.options[:if] = -> { false }
        subject.result = 123
        expect { subject.run(ctx, data) }.to change { subject.result }.from(123).to(nil)
      end
    end

    context 'when an unless proc is given' do
      before { subject.command = -> (*) { 100 } }

      it 'calculates the metric if the proc evaluates to false' do
        subject.options[:unless] = -> { false }
        expect(subject.run(ctx, data)).to eq(100)
      end

      it 'does not calculate the metric if the proc evaluates to true' do
        subject.options[:unless] = -> { true }
        expect(subject.run(ctx, data)).to be_nil
      end

      it 'sets the result to nil if the proc evaluates to true' do
        subject.options[:unless] = -> { true }
        subject.result = 123
        expect { subject.run(ctx, data) }.to change { subject.result }.from(123).to(nil)
      end
    end
  end

  describe '#ran?' do
    it 'returns true if there are any results' do
      allow(subject).to receive_messages(result: 123)
      expect(subject).to have_ran
    end

    it 'returns false if there are no results' do
      expect(subject).to_not have_ran
    end
  end
end
