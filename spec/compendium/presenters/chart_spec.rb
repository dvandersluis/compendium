require 'compendium/presenters/chart'

RSpec.describe Compendium::Presenters::Chart do
  let(:template) do
    double(
      'Template',
      protect_against_forgery?: false,
      request_forgery_protection_token: :authenticity_token,
      form_authenticity_token: 'ABCDEFGHIJ'
    ).as_null_object
  end
  let(:query) { double('Query', name: 'test_query', results: results, ran?: true, options: {}).as_null_object }
  let(:results) { Compendium::ResultSet.new([]) }

  before do
    allow_any_instance_of(described_class).to receive(:provider) { double('ChartProvider') }
    allow_any_instance_of(described_class).to receive(:initialize_chart_provider)
  end

  describe '#initialize' do
    context 'when all params are given' do
      subject { described_class.new(template, query, :pie, :container) }

      specify { expect(subject.data).to eq(results.records) }
      specify { expect(subject.container).to eq(:container) }
    end

    context 'when container is not given' do
      subject { described_class.new(template, query, :pie) }

      specify { expect(subject.data).to eq(results.records) }
      specify { expect(subject.container).to eq('test_query') }
    end

    context 'when options are given' do
      before { allow(results).to receive(:records).and_return(one: []) }

      subject { described_class.new(template, query, :pie, index: :one) }

      specify { expect(subject.data).to eq(results.records[:one]) }
      specify { expect(subject.container).to eq('test_query') }
    end

    context 'when the query has not been run' do
      before { allow(query).to receive_messages(ran?: false, url: '/path/to/query.json') }

      subject { described_class.new(template, query, :pie, params: { foo: 'bar' }) }

      specify { expect(subject.data).to eq('/path/to/query.json') }
      specify { expect(subject.params).to eq(report: { foo: 'bar' }) }

      context 'when CSRF protection is enabled' do
        before { allow(template).to receive_messages(protect_against_forgery?: true) }

        specify { expect(subject.params).to include authenticity_token: 'ABCDEFGHIJ' }
      end

      context 'when CSRF protection is disabled' do
        specify { expect(subject.params).to_not include authenticity_token: 'ABCDEFGHIJ' }
      end
    end
  end

  describe '#remote?' do
    it 'returns true if options[:remote] is set to true' do
      expect(described_class.new(template, query, :pie, remote: true)).to be_remote
    end

    it 'returns true if the query has not been run yet' do
      allow(query).to receive_messages(run?: false)
      described_class.new(template, query, :pie).should_be_remote
    end

    it 'returns false otherwise' do
      expect(described_class.new(template, query, :pie)).to_not be_remote
    end
  end
end
