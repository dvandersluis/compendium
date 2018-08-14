require 'compendium/param_types/scalar'

RSpec.describe Compendium::ParamTypes::Scalar do
  subject { described_class.new(123) }

  it { is_expected.to be_scalar }
  it { is_expected.to_not be_boolean }
  it { is_expected.to_not be_date }
  it { is_expected.to_not be_dropdown }
  it { is_expected.to_not be_radio }

  it 'does not change values' do
    expect(subject).to eq(123)
  end
end
