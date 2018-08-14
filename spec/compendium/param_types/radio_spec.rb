require 'compendium/param_types/radio'

RSpec.describe Compendium::ParamTypes::Radio do
  subject { described_class.new(0, %w(a b c)) }

  it { is_expected.to_not be_scalar }
  it { is_expected.to_not be_boolean }
  it { is_expected.to_not be_date }
  it { is_expected.to_not be_dropdown }
  it { is_expected.to be_radio }
end
