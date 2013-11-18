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

    its(:options) { should include :starting_on }
    specify { subject.options[:starting_on].should be_date }

    it "should allow previously defined options to be redefined" do
      subject.option :starting_on, :boolean
      subject.options[:starting_on].should be_boolean
      subject.options[:starting_on].should_not be_date
    end

    it "should allow overriding default value" do
      proc = -> { Date.new(2013, 6, 1) }
      subject.option :starting_on, :date, default: proc
      subject.options[:starting_on].default.should == proc
    end

    it "should add validations" do
      subject.option :foo, validates: { presence: true }
      subject.params_class.validators_on(:foo).should_not be_empty
    end

    it "should not add validations if no validates option is given" do
      subject.params_class.should_not_receive :validates
      subject.option :foo
    end

    it "should not bleed overridden options into the superclass" do
      r = Class.new(subject)
      r.option :starting_on, :boolean
      r.option :new, :date
      subject.options[:starting_on].should be_date
    end
  end

  describe "#query" do
    let(:report_class) do
      Class.new(Compendium::Report) do
        query :test
      end
    end

    subject { report_class }

    its(:queries) { should include :test }

    it "should relate the new query back to the report instance" do
      r = subject.new
      r.test.report.should == r
    end

    it "should not relate a query to the report class" do
      subject.test.report.should be_nil
    end

    context "when given a through option" do
      before { report_class.query :through, through: :test }
      subject { report_class.queries[:through] }

      it { should be_a Compendium::ThroughQuery }
      its(:through) { should == [:test] }
    end

    context "when given a collection option" do
      subject { report_class.queries[:collection] }

      context "that is an enumerable" do
        before { report_class.query :collection, collection: [] }

        it { should be_a Compendium::CollectionQuery }
      end

      context "that is a symbol" do
        let(:query) { double("Query") }

        before do
          Compendium::Query.any_instance.stub(:get_associated_query).with(:query).and_return(query)
          report_class.query :collection, collection: :query
        end

        its(:collection) { should == :query }
      end

      context "that is a query" do
        let(:query) { Compendium::Query.new(:query, {}, ->{}) }
        before { report_class.query :collection, collection: query }

        its(:collection) { should == query }
      end
    end
  end

  describe "#chart" do
    before { subject.chart(:chart) }

    its(:queries) { should include :chart }
  end

  describe "#data" do
    before { subject.data(:data) }

    its(:queries) { should include :data }
  end

  describe "#metric" do
    let(:metric_proc) { ->{ :metric } }

    before do
      subject.query :test
      subject.metric :test_metric, metric_proc, through: :test
    end

    it "should add a metric to the given query" do
      subject.queries[:test].metrics.first.name.should == :test_metric
    end

    it "should set the metric command" do
      subject.queries[:test].metrics.first.command.should == metric_proc
    end

    it "should raise an error if through is not specified" do
      expect{ subject.metric :test_metric, metric_proc }.to raise_error ArgumentError, 'through option must be specified for metric'
    end

    it "should raise an error if specified for an invalid query" do
      expect{ subject.metric :test_metric, metric_proc, through: :fake }.to raise_error ArgumentError, 'query fake is not defined'
    end

    it "should allow metrics to be defined with a block" do
      subject.metric :block_metric, through: :test do
        123
      end

      subject.queries[:test].metrics[:block_metric].run(self, nil).should == 123
    end

    it "should allow metrics to be defined with a lambda" do
      subject.metric :block_metric, -> * { 123 }, through: :test
      subject.queries[:test].metrics[:block_metric].run(self, nil).should == 123
    end
  end

  it "should allow previously defined queries to be redefined by name" do
    subject.query :test_query
    subject.test_query foo: :bar
    subject.queries[:test_query].options.should == { foo: :bar }
  end

  it "should allow previously defined queries to be accessed by name" do
    subject.query :test_query
    subject.test_query.should == subject.queries[:test_query]
  end
end