require 'spec_helper'
require 'compendium/param_types/date'

describe Compendium::ParamTypes::Date do
  subject{ described_class.new(Date.today) }

  it { is_expected.not_to be_scalar }
  it { is_expected.not_to be_boolean }
  it { is_expected.to be_date }
  it { is_expected.not_to be_dropdown }
  it { is_expected.not_to be_radio }

  it "should convert date strings to date objects" do
    p = described_class.new("2010-05-20")
    expect(p).to eq(Date.new(2010, 5, 20))
  end

  it "should convert other date/time formats to date objects" do
    described_class.new(DateTime.new(2010, 5, 20, 10, 30, 59)) == Date.new(2010, 5, 20)
    described_class.new(Time.new(2010, 5, 20, 10, 30, 59)) == Date.new(2010, 5, 20)
    described_class.new(Date.new(2010, 5, 20)) == Date.new(2010, 5, 20)
  end
end
