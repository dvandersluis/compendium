require 'spec_helper'
require 'compendium'
require 'compendium/dsl'

describe Compendium::DSL do
  subject do
    Class.new do
      extend Compendium::DSL
    end
  end

  describe "#option" do
    before { subject.option :starting_on, :date }

    specify { expect(subject.options).to include :starting_on }
    specify { expect(subject.options[:starting_on]).to be_date }

    it "should allow previously defined options to be redefined" do
      subject.option :starting_on, :boolean
      expect(subject.options[:starting_on]).to be_boolean
      expect(subject.options[:starting_on]).not_to be_date
    end

    it "should allow overriding default value" do
      proc = -> { Date.new(2013, 6, 1) }
      subject.option :starting_on, :date, default: proc
      expect(subject.options[:starting_on].default).to eq(proc)
    end

    it "should add validations" do
      subject.option :foo, validates: { presence: true }
      expect(subject.params_class.validators_on(:foo)).not_to be_empty
    end

    it "should not add validations if no validates option is given" do
      expect(subject.params_class).not_to receive :validates
      subject.option :foo
    end

    it "should not bleed overridden options into the superclass" do
      r = Class.new(subject)
      r.option :starting_on, :boolean
      r.option :new, :date
      expect(subject.options[:starting_on]).to be_date
    end
  end

  describe "#query" do
    let(:proc1) { -> { :proc1 } }
    let(:proc2) { -> { :proc2 } }

    let(:report_class) do
      proc1 = proc1

      Class.new(Compendium::Report) do
        query :test, &proc1
      end
    end

    subject { report_class }

    specify { expect(subject.queries).to include :test }

    it "should relate the new query back to the report instance" do
      r = subject.new
      expect(r.test.report).to eq(r)
    end

    it "should relate a query to the report class" do
      expect(subject.test.report).to eq(subject)
    end

    context 'when overriding an existing query' do
      before do
        subject.query :test, &proc2
        subject.query :another_test, count: true
      end

      it 'should delete the existing query' do
        expect(subject.queries.count).to eq(2)
      end

      it 'should only have one query with each name' do
        expect(subject.queries.map(&:name)).to match_array([:test, :another_test])
      end

      it 'should use the new proc' do
        expect(subject.test.proc).to eq(proc2)
      end

      it 'should not allow replacing a query with a different type' do
        expect { subject.query :test, count: true }.to raise_error { Compendium::CannotRedefineQueryType }
        expect(subject.test).to be_instance_of Compendium::Query
      end

      it 'should allow replacing a query with the same type' do
        subject.query :another_test, count: true, &proc2
        expect(subject.another_test.proc).to eq(proc2)
        expect(subject.another_test).to be_instance_of Compendium::CountQuery
      end
    end

    context "when given a through option" do
      before { report_class.query :through, through: :test }
      subject { report_class.queries[:through] }

      specify { is_expected.to be_a Compendium::ThroughQuery }
      specify { expect(subject.through).to eq([:test]) }
    end

    context "when given a collection option" do
      subject { report_class.queries[:collection] }

      context "that is an enumerable" do
        before { report_class.query :collection, collection: [] }

        it { is_expected.to be_a Compendium::CollectionQuery }
      end

      context "that is a symbol" do
        let(:query) { double("Query") }

        before do
          allow_any_instance_of(Compendium::Query).to receive(:get_associated_query).with(:query).and_return(query)
          report_class.query :collection, collection: :query
        end

        specify { expect(subject.collection).to eq(:query) }
      end

      context "that is a query" do
        let(:query) { Compendium::Query.new(:query, {}, ->{}) }
        before { report_class.query :collection, collection: query }

        specify { expect(subject.collection).to eq(query) }
      end
    end

    context "when given a count option" do
      subject{ report_class.queries[:counted] }

      context "set to true" do
        before { report_class.query :counted, count: true }
        it { is_expected.to be_a Compendium::CountQuery }
      end

      context "set to false" do
        before { report_class.query :counted, count: false }
        it { is_expected.to be_a Compendium::Query }
        it { is_expected.not_to be_a Compendium::CountQuery }
      end
    end

    context 'when given a sum option' do
      subject{ report_class.queries[:summed] }

      context 'set to a truthy value' do
        before { report_class.query :summed, sum: :assoc_count }

        it { is_expected.to be_a Compendium::SumQuery }
        specify { expect(subject.column).to eq(:assoc_count) }
      end

      context 'set to false' do
        before { report_class.query :summed, sum: false }
        it { is_expected.to be_a Compendium::Query }
        it { is_expected.not_to be_a Compendium::SumQuery }
      end
    end
  end

  describe "#chart" do
    before { subject.chart(:chart) }
    specify { expect(subject.queries).to include :chart }
  end

  describe "#data" do
    before { subject.data(:data) }
    specify { expect(subject.queries).to include :data }
  end

  describe "#metric" do
    let(:metric_proc) { ->{ :metric } }

    before do
      subject.query :test
      subject.metric :test_metric, metric_proc, through: :test
    end

    it "should add a metric to the given query" do
      expect(subject.queries[:test].metrics.first.name).to eq(:test_metric)
    end

    it "should set the metric command" do
      expect(subject.queries[:test].metrics.first.command).to eq(metric_proc)
    end

    context "when through is specified" do
      it "should raise an error if specified for an invalid query" do
        expect{ subject.metric :test_metric, metric_proc, through: :fake }.to raise_error ArgumentError, 'query fake is not defined'
      end

      it "should allow metrics to be defined with a block" do
        subject.metric :block_metric, through: :test do
          123
        end

        expect(subject.queries[:test].metrics[:block_metric].run(self, nil)).to eq(123)
      end

      it "should allow metrics to be defined with a lambda" do
        subject.metric :block_metric, -> * { 123 }, through: :test
        expect(subject.queries[:test].metrics[:block_metric].run(self, nil)).to eq(123)
      end
    end

    context "when through is not specified" do
      before { subject.metric(:no_through_metric) { |data| data } }

      specify { expect(subject.queries).to include :__metric_no_through_metric }

      it "should return the result of the query as the result of the metric" do
        expect(subject.queries[:__metric_no_through_metric].metrics[:no_through_metric].run(self, [123])).to eq(123)
      end
    end
  end

  describe "#filter" do
    let(:filter_proc) { ->{ :filter } }

    it "should add a filter to the given query" do
      subject.query :test
      subject.filter :test, &filter_proc
      expect(subject.queries[:test].filters).to include filter_proc
    end

    it "should raise an error if there is no query of the given name" do
      expect { subject.filter :test, &filter_proc }.to raise_error(ArgumentError, "query test is not defined")
    end

    it "should allow multiple filters to be defined for the same query" do
      subject.query :test
      subject.filter :test, &filter_proc
      subject.filter :test, &->{ :another_filter }
      expect(subject.queries[:test].filters.count).to eq(2)
    end

    it "should allow a filter to be applied to multiple queries at once" do
      subject.query :query1
      subject.query :query2
      subject.filter :query1, :query2, &filter_proc
      expect(subject.queries[:query1].filters).to include filter_proc
      expect(subject.queries[:query2].filters).to include filter_proc
    end
  end

  describe '#table' do
    let(:table_proc) { -> { display_nil_as 'na' } }

    it 'should add table settings to the given query' do
      subject.query :test
      subject.table :test, &table_proc
      expect(subject.queries[:test].table_settings).to eq(table_proc)
    end

    it 'should raise an error if there is no query of the given name' do
      expect { subject.table :test, &table_proc }.to raise_error(ArgumentError, "query test is not defined")
    end

    it 'should allow table settings to be applied to multiple queries at once' do
      subject.query :query1
      subject.query :query2
      subject.table :query1, :query2, &table_proc
      expect(subject.queries[:query1].table_settings).to eq(table_proc)
      expect(subject.queries[:query2].table_settings).to eq(table_proc)
    end
  end

  describe '#exports' do
    it 'should not have any exporters by default' do
      expect(subject.exporters).to be_empty
    end

    it 'should set the export to true if no options are given' do
      subject.exports :csv
      expect(subject.exporters[:csv]).to eq(true)
    end

    it 'should save any given options' do
      subject.exports :csv, :main_query
      subject.exports :pdf, :foo, :bar
      expect(subject.exporters[:csv]).to eq(:main_query)
      expect(subject.exporters[:pdf]).to eq([:foo, :bar])
    end
  end

  it "should allow previously defined queries to be redefined by name" do
    subject.query :test_query
    subject.test_query foo: :bar
    expect(subject.queries[:test_query].options).to eq({ foo: :bar })
  end

  it "should allow previously defined queries to be accessed by name" do
    subject.query :test_query
    expect(subject.test_query).to eq(subject.queries[:test_query])
  end
end
