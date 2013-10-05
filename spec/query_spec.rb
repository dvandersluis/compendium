require 'compendium/query'

describe Compendium::Query do
  describe "#run" do
    before { described_class.any_instance.stub(:fetch_results) { |cmd| cmd } }

    it "should return the result of the query" do
      query = Compendium::Query.new(:test, {}, -> *_ { 123 })
      query.run(nil).should == 123
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
