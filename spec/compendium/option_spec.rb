require 'compendium/option'

RSpec.describe Compendium::Option do
  it 'raises an ArgumentError if no name is given' do
    expect { described_class.new }.to raise_error ArgumentError, 'name must be provided'
  end

  it 'sets up type predicates from the type option' do
    o = described_class.new(name: :option, type: :date)
    expect(o).to be_date
  end
end
