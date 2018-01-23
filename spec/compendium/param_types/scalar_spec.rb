require 'spec_helper'
require 'compendium/param_types/scalar'

describe Compendium::ParamTypes::Scalar do
  subject{ described_class.new(123) }

  it { is_expected.to be_scalar }
  it { is_expected.not_to be_boolean }
  it { is_expected.not_to be_date }
  it { is_expected.not_to be_dropdown }
  it { is_expected.not_to be_radio }

  it "should not change values" do
    expect(subject).to eq(123)
  end
end
