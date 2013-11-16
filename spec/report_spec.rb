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
    context do
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
        Compendium::Query.any_instance.stub(:fetch_results) { |c| c }
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

      context "with through queries" do
        let(:report_class) do
          Class.new(Compendium::Report) do
            option :first, :boolean, default: false
            query(:test) { |params| !!params[:first] ? [100, 200, 400, 800] : [1600, 3200, 6400]}
            query(:through, through: :test) { |results| [results.first] }
          end
        end

        subject { report_class.new(first: true) }

        its('through.results') { should == [100] }

        it "should not mark other instances' queries as ran" do
          report2.test.should_not have_run
        end

        it "should not affect other instances" do
          report2.queries.each { |q| q.stub(:fetch_results) { |c| c } }
          report2.run
          report2.through.results.should == [1600]
        end
      end
    end

    context "when specifying which queries to run" do
      let(:report_class) do
        Class.new(Compendium::Report) do
          query :first
          query :second
        end
      end

      subject { report_class.new }

      it "should raise an error if given :only and :except options" do
        expect{ subject.run(nil, only: :first, except: :second) }.to raise_error(ArgumentError)
      end

      it "should raise an error if given an invalid query name" do
        expect{ subject.run(nil, only: :foo) }.to raise_error(ArgumentError)
      end

      it "should run all queries if nothing is specified" do
        subject.run(nil)
        subject.first.should have_run
        subject.second.should have_run
      end

      it "should only run queries specified by :only" do
        subject.run(nil, only: :first)
        subject.first.should have_run
        subject.second.should_not have_run
      end

      it "should not run queries specified by :except" do
        subject.run(nil, except: :first)
        subject.first.should_not have_run
        subject.second.should have_run
      end
    end
  end

  describe "predicate methods" do
    before do
      OneReport = Class.new(Compendium::Report)
      TwoReport = Class.new(Compendium::Report)
      ThreeReport = Class.new
    end

    after do
      Object.send(:remove_const, :OneReport)
      Object.send(:remove_const, :TwoReport)
      Object.send(:remove_const, :ThreeReport)
    end

    it { should respond_to(:one?) }
    it { should respond_to(:two?) }
    it { should_not respond_to(:three?) }

    it { should_not be_one }
    it { should_not be_two }

    specify { OneReport.should be_one }
    specify { TwoReport.should be_two }
  end

  describe "parameters" do
    let(:report_class) { Class.new(subject) }
    let(:report_class2) { Class.new(report_class) }

    it "should include ancestors params" do
      report_class.params_class.ancestors.should include subject.params_class
    end

    it "should inherit validations" do
      report_class.params_class.validates :foo, presence: true
      report_class2.params_class.validators_on(:foo).should_not be_nil
    end
  end
end
