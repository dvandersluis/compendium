require 'compendium/queries/query'

RSpec.describe Compendium::Queries::Query do
  describe '#initialize' do
    let(:options) { double('Options', assert_valid_keys: true) }
    let(:proc) { double('Proc') }

    context 'when supplying a report' do
      let(:r) { Compendium::Report.new }

      subject { described_class.new(r, :test, options, proc) }

      specify { expect(subject.report).to eq(r) }
      specify { expect(subject.name).to eq(:test) }
      specify { expect(subject.options).to eq(options) }
      specify { expect(subject.proc).to eq(proc) }
    end

    context 'when not supplying a report' do
      subject { described_class.new(:test, options, proc) }

      specify { expect(subject.report).to be_nil }
      specify { expect(subject.name).to eq(:test) }
      specify { expect(subject.options).to eq(options) }
      specify { expect(subject.proc).to eq(proc) }
    end
  end

  describe '#run' do
    let(:command) { -> (*) { [{ value: 1 }, { value: 2 }] } }
    let(:query) do
      described_class.new(:test, {}, command)
    end

    before do
      allow(query).to receive(:fetch_results) { |c| c }
    end

    it 'returns the result of the query' do
      results = query.run(nil)
      expect(results).to be_a Compendium::ResultSet
      expect(results.to_a).to eq([{ 'value' => 1 }, { 'value' => 2 }])
    end

    it 'marks the query as having ran' do
      query.run(nil)
      expect(query).to have_run
    end

    it 'does not affect any cloned queries' do
      q2 = query.clone
      query.run(nil)
      expect(q2).to_not have_run
    end

    it 'returns an empty result set if running an query with no proc' do
      query = described_class.new(:blank, {}, nil)
      expect(query.run(nil)).to be_empty
    end

    it 'filters the result set if a filter is provided' do
      query.add_filter(-> (data) { data.reject { |d| d[:value].odd? } })
      expect(query.run(nil).to_a).to eq([{ 'value' => 2 }])
    end

    it 'runs multiple filters if given' do
      query.add_filter(-> (data) { data.reject { |d| d[:value].odd? } })
      query.add_filter(-> (data) { data.reject { |d| d[:value].even? } })
      expect(query.run(nil)).to be_empty
    end

    it 'allows the result set to be a single hash when filters are present' do
      query = described_class.new(:test, {}, -> (*) { { value1: 1, value2: 2, value3: 3 } })
      allow(query).to receive(:fetch_results) { |c| c }

      query.add_filter(-> (d) { d })
      query.run(nil)
      expect(query.results.records).to eq({ value1: 1, value2: 2, value3: 3 }.with_indifferent_access)
    end

    context 'ordering' do
      let(:cmd) do
        cmd = double('Command')
        allow(cmd).to receive_messages(order: cmd, reverse_order: cmd)
        cmd
      end

      let(:command) do
        -> (c) { -> (*) { c } }.call(cmd)
      end

      before { query.options[:order] = 'col1' }

      it 'orders the query' do
        expect(cmd).to receive(:order)
        query.run(nil)
      end

      it 'does not reverse the order by default' do
        expect(cmd).to_not receive(:reverse_order)
        query.run(nil)
      end

      it 'reverses the order if the query is given reverse: true' do
        query.options[:reverse] = true
        expect(cmd).to receive(:reverse_order)
        query.run(nil)
      end
    end

    context 'when the query belongs to a report class' do
      let(:report) do
        Class.new(Compendium::Report) do
          query(:test) { [1, 2, 3] }
        end
      end

      subject { report.queries[:test] }

      before { allow_any_instance_of(described_class).to receive(:fetch_results) { |_instance, c| c } }

      it 'returns its results' do
        expect(subject.run(nil)).to eq([1, 2, 3])
      end

      it 'does not affect the report' do
        subject.run(nil)
        expect(report.queries[:test].results).to be_nil
      end

      it 'does not affect future instances of the report' do
        subject.run(nil)
        expect(report.new.queries[:test].results).to be_nil
      end
    end
  end

  describe '#nil?' do
    it "returns true if the query's proc is nil" do
      expect(described_class.new(:test, {}, nil)).to be_nil
    end

    it "returns false if the query's proc is not nil" do
      expect(described_class.new(:test, {}, -> {})).to_not be_nil
    end
  end

  describe '#render_chart' do
    let(:template) { double('Template') }

    subject { described_class.new(:test, {}, -> (*) {}) }

    it 'initializes a new Chart presenter if the query has no results' do
      allow(subject).to receive_messages(empty?: true)
      expect(Compendium::Presenters::Chart).to receive(:new).with(template, subject).and_return(double('Presenter').as_null_object)
      subject.render_chart(template)
    end

    it 'initializes a new Chart presenter if the query has results' do
      allow(subject).to receive_messages(empty?: false)
      expect(Compendium::Presenters::Chart).to receive(:new).with(template, subject).and_return(double('Presenter').as_null_object)
      subject.render_chart(template)
    end
  end

  describe '#render_table' do
    let(:template) { double('Template') }

    subject { described_class.new(:test, {}, -> (*) {}) }

    it 'returns nil if the query has no results' do
      allow(subject).to receive_messages(empty?: true)
      expect(subject.render_table(template)).to be_nil
    end

    it 'initializes a new Table presenter if the query has results' do
      allow(subject).to receive_messages(empty?: false)
      expect(Compendium::Presenters::Table).to receive(:new).with(template, subject).and_return(double('Presenter').as_null_object)
      subject.render_table(template)
    end
  end

  describe '#url' do
    let(:report) { double('Report') }

    subject { described_class.new(:test, {}, -> {}) }

    before { subject.report = report }

    it "builds a URL using its report's URL" do
      expect(report).to receive(:url).with(query: :test)
      subject.url
    end
  end
end
