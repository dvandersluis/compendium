require 'spec_helper'
require 'compendium/param_types/boolean'

describe Compendium::ParamTypes::Boolean do
  subject { described_class.new(true) }

  it { is_expected.not_to be_scalar }
  it { is_expected.to be_boolean }
  it { is_expected.not_to be_date }
  it { is_expected.not_to be_dropdown }
  it { is_expected.not_to be_radio }

  it 'should pass along 0 and 1' do
    expect(described_class.new(0)).to eq(0)
    expect(described_class.new(1)).to eq(1)
  end

  it 'should convert a numeric string to a number' do
    expect(described_class.new('0')).to eq(0)
    expect(described_class.new('1')).to eq(1)
  end

  it 'should return 0 for a truthy value' do
    expect(described_class.new(true)).to eq(0)
    expect(described_class.new(:abc)).to eq(0)
  end

  it 'should return 1 for a falsey value' do
    expect(described_class.new(false)).to eq(1)
    expect(described_class.new(nil)).to eq(1)
  end

  describe '#value' do
    it 'should return true for a truthy value' do
      expect(described_class.new(true).value).to eq(true)
      expect(described_class.new(:abc).value).to eq(true)
      expect(described_class.new(0).value).to eq(true)
    end

    it 'should return false for a falsey value' do
      expect(described_class.new(false).value).to eq(false)
      expect(described_class.new(nil).value).to eq(false)
      expect(described_class.new(1).value).to eq(false)
    end
  end

  describe '#!' do
    it 'should return false if the boolean is true' do
      expect(!described_class.new(true)).to eq(false)
    end

    it 'should return true if the boolean is false' do
      expect(!described_class.new(false)).to eq(true)
    end
  end
end
