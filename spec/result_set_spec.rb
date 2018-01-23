require 'compendium/result_set'

describe Compendium::ResultSet do
  describe "#initialize" do
    subject{ described_class.new(results).records }

    context "when given an array" do
      let(:results) { [1, 2, 3] }
      it { is_expected.to eq([1, 2, 3]) }
    end

    context "when given an array of hashes" do
      let(:results) { [{one: 1}, {two: 2}] }
      it { is_expected.to eq([{"one" => 1}, {"two" => 2}]) }
      specify { expect(subject.first).to be_a ActiveSupport::HashWithIndifferentAccess }
    end

    context "when given a hash" do
      let(:results) { { one: 1, two: 2 } }
      it { is_expected.to eq({ one: 1, two: 2 }) }
    end

    context "when given a scalar" do
      let(:results) { 3 }
      it { is_expected.to eq([3]) }
    end
  end
end
