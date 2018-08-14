require 'compendium/param_types/boolean'

RSpec.describe Compendium::ParamTypes::Boolean do
  subject { described_class.new(true) }

  it { is_expected.to_not be_scalar }
  it { is_expected.to be_boolean }
  it { is_expected.to_not be_date }
  it { is_expected.to_not be_dropdown }
  it { is_expected.to_not be_radio }

  it 'passes along 0 and 1' do
    expect(described_class.new(0)).to eq(0)
    expect(described_class.new(1)).to eq(1)
  end

  it 'converts a numeric string to a number' do
    expect(described_class.new('0')).to eq(0)
    expect(described_class.new('1')).to eq(1)
  end

  it 'returns 0 for a truthy value' do
    expect(described_class.new(true)).to eq(0)
    expect(described_class.new(:abc)).to eq(0)
  end

  it 'returns 1 for a falsey value' do
    expect(described_class.new(false)).to eq(1)
    expect(described_class.new(nil)).to eq(1)
  end

  describe '#value' do
    it 'returns true for a truthy value' do
      expect(described_class.new(true).value).to eq(true)
      expect(described_class.new(:abc).value).to eq(true)
      expect(described_class.new(0).value).to eq(true)
    end

    it 'returns false for a falsey value' do
      expect(described_class.new(false).value).to eq(false)
      expect(described_class.new(nil).value).to eq(false)
      expect(described_class.new(1).value).to eq(false)
    end
  end

  describe '#!' do
    it 'returns false if the boolean is true' do
      expect(!described_class.new(true)).to eq(false)
    end

    it 'returns true if the boolean is false' do
      expect(!described_class.new(false)).to eq(true)
    end
  end
end
