require 'compendium/param_types/param'

RSpec.describe Compendium::ParamTypes::Param do
  subject { described_class.new(:test) }

  it { is_expected.to_not be_scalar }
  it { is_expected.to_not be_boolean }
  it { is_expected.to_not be_date }
  it { is_expected.to_not be_dropdown }
  it { is_expected.to_not be_radio }

  describe '#==' do
    it "compares to the param's value" do
      expect(subject).to eq(:test)
    end
  end
end
