require 'compendium/param_types'

describe Compendium::Param do
  subject{ described_class.new(:test) }

  it { is_expected.not_to be_scalar }
  it { is_expected.not_to be_boolean }
  it { is_expected.not_to be_date }
  it { is_expected.not_to be_dropdown }
  it { is_expected.not_to be_radio }

  describe "#==" do
    it "should compare to the param's value" do
      allow(subject).to receive_messages(value: :test_value)
      expect(subject).to eq(:test_value)
    end
  end
end

describe Compendium::ScalarParam do
  subject{ described_class.new(123) }

  it { is_expected.to be_scalar }
  it { is_expected.not_to be_boolean }
  it { is_expected.not_to be_date }
  it { is_expected.not_to be_dropdown }
  it { is_expected.not_to be_radio }

  it "should not change values" do
    expect(subject).to eq(123)
  end
end

describe Compendium::ParamWithChoices do
  subject{ described_class.new(0, %w(a b c)) }

  it { is_expected.not_to be_boolean }
  it { is_expected.not_to be_date }
  it { is_expected.not_to be_dropdown }
  it { is_expected.not_to be_radio }

  it "should return the index when given an index" do
    p = described_class.new(1, [:foo, :bar, :baz])
    expect(p).to eq(1)
  end

  it "should return the index when given a value" do
    p = described_class.new(:foo, [:foo, :bar, :baz])
    expect(p).to eq(0)
  end

  it "should return the index when given a string value" do
    p = described_class.new("2", [:foo, :bar, :baz])
    expect(p).to eq(2)
  end

  it "should raise an error if given an invalid index" do
    expect { described_class.new(3, [:foo, :bar, :baz]) }.to raise_error IndexError
  end

  it "should raise an error if given a value that is not included in the choices" do
    expect { described_class.new(:quux, [:foo, :bar, :baz]) }.to raise_error IndexError
  end

  describe "#value" do
    it "should return the value of the given choice" do
      p = described_class.new(2, [:foo, :bar, :baz])
      expect(p.value).to eq(:baz)
    end
  end
end

describe Compendium::BooleanParam do
  subject{ described_class.new(true) }

  it { is_expected.not_to be_scalar }
  it { is_expected.to be_boolean }
  it { is_expected.not_to be_date }
  it { is_expected.not_to be_dropdown }
  it { is_expected.not_to be_radio }

  it "should pass along 0 and 1" do
    expect(described_class.new(0)).to eq(0)
    expect(described_class.new(1)).to eq(1)
  end

  it "should convert a numeric string to a number" do
    expect(described_class.new('0')).to eq(0)
    expect(described_class.new('1')).to eq(1)
  end

  it "should return 0 for a truthy value" do
    expect(described_class.new(true)).to eq(0)
    expect(described_class.new(:abc)).to eq(0)
  end

  it "should return 1 for a falsey value" do
    expect(described_class.new(false)).to eq(1)
    expect(described_class.new(nil)).to eq(1)
  end

  describe "#value" do
    it "should return true for a truthy value" do
      expect(described_class.new(true).value).to eq(true)
      expect(described_class.new(:abc).value).to eq(true)
      expect(described_class.new(0).value).to eq(true)
    end

    it "should return false for a falsey value" do
      expect(described_class.new(false).value).to eq(false)
      expect(described_class.new(nil).value).to eq(false)
      expect(described_class.new(1).value).to eq(false)
    end
  end

  describe "#!" do
    it "should return false if the boolean is true" do
      expect(!described_class.new(true)).to eq(false)
    end

    it "should return true if the boolean is false" do
      expect(!described_class.new(false)).to eq(true)
    end
  end
end

describe Compendium::DateParam do
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

describe Compendium::DropdownParam do
  subject{ described_class.new(0, %w(a b c)) }

  it { is_expected.not_to be_scalar }
  it { is_expected.not_to be_boolean }
  it { is_expected.not_to be_date }
  it { is_expected.to be_dropdown }
  it { is_expected.not_to be_radio }
end

describe Compendium::RadioParam do
  subject{ described_class.new(0, %w(a b c)) }

  it { is_expected.not_to be_scalar }
  it { is_expected.not_to be_boolean }
  it { is_expected.not_to be_date }
  it { is_expected.not_to be_dropdown }
  it { is_expected.to be_radio }
end
