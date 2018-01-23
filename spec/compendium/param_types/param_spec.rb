require 'spec_helper'
require 'compendium/param_types/param'

describe Compendium::ParamTypes::Param do
  subject{ described_class.new(:test) }

  it { is_expected.not_to be_scalar }
  it { is_expected.not_to be_boolean }
  it { is_expected.not_to be_date }
  it { is_expected.not_to be_dropdown }
  it { is_expected.not_to be_radio }

  describe "#==" do
    it "should compare to the param's value" do
      allow(subject).to receive_messages(value: :test_value)
      expect(subject).to eq(:test_value)
    end
  end
end
