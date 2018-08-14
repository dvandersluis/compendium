require 'compendium'
require 'compendium/dsl'

RSpec.describe Compendium::DSL::Metric do
  subject do
    Class.new do
      extend Compendium::DSL
    end
  end

  describe '#metric' do
    let(:metric_proc) { -> { :metric } }

    before do
      subject.query :test
      subject.metric :test_metric, metric_proc, through: :test
    end

    it 'adds a metric to the given query' do
      expect(subject.queries[:test].metrics.first.name).to eq(:test_metric)
    end

    it 'sets the metric command' do
      expect(subject.queries[:test].metrics.first.command).to eq(metric_proc)
    end

    context 'when through is specified' do
      it 'raises an error if specified for an invalid query' do
        expect { subject.metric :test_metric, metric_proc, through: :fake }.to raise_error ArgumentError, 'query fake is not defined'
      end

      it 'allows metrics to be defined with a block' do
        subject.metric :block_metric, through: :test do
          123
        end

        expect(subject.queries[:test].metrics[:block_metric].run(self, nil)).to eq(123)
      end

      it 'allows metrics to be defined with a lambda' do
        subject.metric :block_metric, -> (*) { 123 }, through: :test
        expect(subject.queries[:test].metrics[:block_metric].run(self, nil)).to eq(123)
      end
    end

    context 'when through is not specified' do
      before { subject.metric(:no_through_metric) { |data| data } }

      specify { expect(subject.queries).to include :__metric_no_through_metric }

      it 'returns the result of the query as the result of the metric' do
        expect(subject.queries[:__metric_no_through_metric].metrics[:no_through_metric].run(self, [123])).to eq(123)
      end
    end
  end
end
