require 'compendium/report'

describe Compendium::Report do
  subject { described_class }

  its(:queries) { should be_empty }
  its(:options) { should be_empty }

  it "should not do anything when run" do
    report = subject.new
    report.run
    report.results.should be_empty
  end

  context "with multiple instances" do
    let(:report_class) do
      Class.new(Compendium::Report) do
        query :test
        metric :test_metric, ->{}, through: :test
      end
    end

    subject { report_class.new }
    let(:report2) { report_class.new }

    its(:queries) { should_not equal report2.queries }
    its(:queries) { should_not equal report_class.queries }
    its(:metrics) { should_not equal report2.metrics }
  end

  describe "#run" do
    let(:report_class) do
      Class.new(Compendium::Report) do
        option :first, :date
        option :second, :date

        query :test do |params|
          [params[:first].__getobj__, params[:second].__getobj__]
        end

        metric :test_metric, -> results { results.to_a.max }, through: :test
      end
    end

    subject { report_class.new(first: '2010-10-10', second: '2011-11-11') }
    let!(:report2) { report_class.new }

    before do
      subject.test.stub(:fetch_results) { |c| c }
      subject.run
    end

    its('test_results.records') { should == [Date.new(2010, 10, 10), Date.new(2011, 11, 11)] }

    it "should run its metrics" do
      subject.test.metrics[:test_metric].result.should == Date.new(2011, 11, 11)
      subject.metrics[:test_metric].result.should == Date.new(2011, 11, 11)
    end

    it "should not affect other instances of the report class" do
      report2.test.results.should be_nil
      report2.metrics[:test_metric].result.should be_nil
    end

    it "should not affect the class collections" do
      report_class.test.results.should be_nil
    end
  end
end
