require 'compendium/param_types/date'

RSpec.describe Compendium::ParamTypes::Date do
  subject { described_class.new(Date.today) }

  it { is_expected.to_not be_scalar }
  it { is_expected.to_not be_boolean }
  it { is_expected.to be_date }
  it { is_expected.to_not be_dropdown }
  it { is_expected.to_not be_radio }

  it 'converts date strings to date objects' do
    p = described_class.new('2010-05-20')
    expect(p).to eq(Date.new(2010, 5, 20))
  end

  it 'converts other date/time formats to date objects' do
    expect(described_class.new(DateTime.new(2010, 5, 20, 10, 30, 59))).to eq(Date.new(2010, 5, 20))
    expect(described_class.new(Time.new(2010, 5, 20, 10, 30, 59))).to eq(Date.new(2010, 5, 20))
    expect(described_class.new(Date.new(2010, 5, 20))).to eq(Date.new(2010, 5, 20))
  end
end
