require 'compendium/query'

describe Compendium::Query do
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
  end

  describe "#nil?" do
    it "should return true if the query's proc is nil" do
      Compendium::Query.new(:test, {}, nil).should be_nil
    end

    it "should return false if the query's proc is not nil" do
      Compendium::Query.new(:test, {}, ->{}).should_not be_nil
    end
  end
end
