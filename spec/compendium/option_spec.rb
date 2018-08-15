require 'compendium/option'

RSpec.describe Compendium::Option do
  it 'raises an ArgumentError if no name is given' do
    expect { described_class.new }.to raise_error ArgumentError
  end

  it 'raises an ArgumentError if no type is given' do
    expect { described_class.new(name: 'foo').type }.to raise_error ArgumentError
  end

  it 'sets up type predicates from the type option' do
    option = described_class.new(name: :option, type: :date)
    expect(option).to be_date
  end

  it 'sets options if given' do
    option = described_class.new(name: :option, type: :scalar, foo: 1, bar: 2, baz: 3)
    expect(option.options).to match(foo: 1, bar: 2, baz: 3)
  end
end
