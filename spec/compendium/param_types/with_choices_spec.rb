require 'compendium/param_types/with_choices'

RSpec.describe Compendium::ParamTypes::WithChoices do
  subject { described_class.new(0, %w(a b c)) }

  it { is_expected.to_not be_boolean }
  it { is_expected.to_not be_date }
  it { is_expected.to_not be_dropdown }
  it { is_expected.to_not be_radio }

  it 'returns the index when given an index' do
    p = described_class.new(1, %i(foo bar baz))
    expect(p).to eq(1)
  end

  it 'returns the index when given a value' do
    p = described_class.new(:foo, %i(foo bar baz))
    expect(p).to eq(0)
  end

  it 'returns the index when given a string value' do
    p = described_class.new('2', %i(foo bar baz))
    expect(p).to eq(2)
  end

  it 'raises an error if given an invalid index' do
    expect { described_class.new(3, %i(foo bar baz)) }.to raise_error IndexError
  end

  it 'raises an error if given a value that is not included in the choices' do
    expect { described_class.new(:quux, %i(foo bar baz)) }.to raise_error IndexError
  end

  describe '#value' do
    it 'returns the value of the given choice' do
      p = described_class.new(2, %i(foo bar baz))
      expect(p.value).to eq(:baz)
    end
  end
end
