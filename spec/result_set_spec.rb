require 'compendium/result_set'

describe Compendium::ResultSet do
  describe "#initialize" do
    subject{ described_class.new(results).records }

    context "when given an array" do
      let(:results) { [1, 2, 3] }
      it { should == [1, 2, 3] }
    end

    context "when given an array of hashes" do
      let(:results) { [{one: 1}, {two: 2}] }
      it { should == [{"one" => 1}, {"two" => 2}] }
      its(:first) { should be_a ActiveSupport::HashWithIndifferentAccess }
    end

    context "when given a hash" do
      let(:results) { { one: 1, two: 2 } }
      it { should == { one: 1, two: 2 } }
    end

    context "when given a scalar" do
      let(:results) { 3 }
      it { should == [3] }
    end
  end
end