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
  end

  describe "#query" do
    subject do
      Class.new(Compendium::Report) do
        query :test
      end
    end

    its(:queries) { should include :test }

    it "should relate the new query back to the report instance" do
      r = subject.new
      r.test.report.should == r
    end

    it "should not relate a query to the report class" do
      subject.test.report.should be_nil
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