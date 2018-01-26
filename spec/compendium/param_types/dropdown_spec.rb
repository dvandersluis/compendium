require 'spec_helper'
require 'compendium/param_types/dropdown'

describe Compendium::ParamTypes::Dropdown do
  subject { described_class.new(0, %w(a b c)) }

  it { is_expected.not_to be_scalar }
  it { is_expected.not_to be_boolean }
  it { is_expected.not_to be_date }
  it { is_expected.to be_dropdown }
  it { is_expected.not_to be_radio }
end
