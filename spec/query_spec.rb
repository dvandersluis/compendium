require 'spec_helper'
require 'compendium/query'

describe Compendium::Query do
  describe "#initialize" do
    let(:options) { double("Options") }
    let(:proc) { double("Proc") }

    context "when supplying a report" do
      let(:r) { Compendium::Report.new }
      subject { described_class.new(r, :test, options, proc)}

      its(:report) { should == r }
      its(:name) { should == :test }
      its(:options) { should == options }
      its(:proc) { should == proc }
    end

    context "when not supplying a report" do
      subject { described_class.new(:test, options, proc)}

      its(:report) { should be_nil }
      its(:name) { should == :test }
      its(:options) { should == options }
      its(:proc) { should == proc }
    end
  end

  describe "#run" do
    let(:query) { described_class.new(:test, {}, -> * { [1, 2, 3] }) }
    before { query.stub(:fetch_results) { |c| c } }

    it "should return the result of the query" do
      query.run(nil).should == [1, 2, 3]
    end

    it "should mark the query as having ran" do
      query.run(nil)
      query.should have_run
    end

    it "should not affect any cloned queries" do
      q2 = query.clone
      query.run(nil)
      q2.should_not have_run
    end

    it "should return an empty result set if running an query with no proc" do
      query = described_class.new(:blank, {}, nil)
      query.run(nil).should be_empty
    end

    it "should filter the result set if a filter is provided" do
      query.add_filter(-> data { data.reject(&:odd?) })
      query.run(nil).should == [2]
    end

    it "should run multiple filters if given" do
      query.add_filter(-> data { data.reject(&:odd?) })
      query.add_filter(-> data { data.reject(&:even?) })
      query.run(nil).should == []
    end

    context "when the query belongs to a report class" do
      let(:report) do
        Class.new(Compendium::Report) do
          query(:test) { [1, 2, 3] }
        end
      end

      subject { report.queries[:test] }

      before { described_class.any_instance.stub(:fetch_results) { |c| c } }

      it "should return its results" do
        subject.run(nil).should == [1, 2, 3]
      end

      it "should not affect the report" do
        subject.run(nil)
        report.queries[:test].results.should be_nil
      end

      it "should not affect future instances of the report" do
        subject.run(nil)
        report.new.queries[:test].results.should be_nil
      end
    end
  end

  describe "#nil?" do
    it "should return true if the query's proc is nil" do
      Compendium::Query.new(:test, {}, nil).should be_nil
    end

    it "should return false if the query's proc is not nil" do
      Compendium::Query.new(:test, {}, ->{}).should_not be_nil
    end
  end

  describe "#render_chart" do
    let(:template) { double("Template") }
    subject { described_class.new(:test, {}, -> * {}) }

    it "should initialize a new Chart presenter if the query has no results" do
      subject.stub(empty?: true)
      Compendium::Presenters::Chart.should_receive(:new).with(template, subject).and_return(double("Presenter").as_null_object)
      subject.render_chart(template)
    end

    it "should initialize a new Chart presenter if the query has results" do
      subject.stub(empty?: false)
      Compendium::Presenters::Chart.should_receive(:new).with(template, subject).and_return(double("Presenter").as_null_object)
      subject.render_chart(template)
    end
  end

  describe "#render_table" do
    let(:template) { double("Template") }
    subject { described_class.new(:test, {}, -> * {}) }

    it "should return nil if the query has no results" do
      subject.stub(empty?: true)
      subject.render_table(template).should be_nil
    end

    it "should initialize a new Table presenter if the query has results" do
      subject.stub(empty?: false)
      Compendium::Presenters::Table.should_receive(:new).with(template, subject).and_return(double("Presenter").as_null_object)
      subject.render_table(template)
    end
  end
end
