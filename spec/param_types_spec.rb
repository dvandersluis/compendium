require 'compendium/param_types'

describe Compendium::Param do
  subject{ described_class.new(:test) }

  it { should_not be_scalar }
  it { should_not be_boolean }
  it { should_not be_date }
  it { should_not be_dropdown }
  it { should_not be_radio }

  describe "#==" do
    it "should compare to the param's value" do
      subject.stub(value: :test_value)
      subject.should == :test_value
    end
  end
end

describe Compendium::ScalarParam do
  subject{ described_class.new(123) }

  it { should be_scalar }
  it { should_not be_boolean }
  it { should_not be_date }
  it { should_not be_dropdown }
  it { should_not be_radio }

  it "should not change values" do
    subject.should == 123
  end
end

describe Compendium::ParamWithChoices do
  subject{ described_class.new(0, %w(a b c)) }

  it { should_not be_boolean }
  it { should_not be_date }
  it { should_not be_dropdown }
  it { should_not be_radio }

  it "should return the index when given an index" do
    p = described_class.new(1, [:foo, :bar, :baz])
    p.should == 1
  end

  it "should return the index when given a value" do
    p = described_class.new(:foo, [:foo, :bar, :baz])
    p.should == 0
  end

  it "should return the index when given a string value" do
    p = described_class.new("2", [:foo, :bar, :baz])
    p.should == 2
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
      p.value.should == :baz
    end
  end
end

describe Compendium::BooleanParam do
  subject{ described_class.new(true) }

  it { should_not be_scalar }
  it { should be_boolean }
  it { should_not be_date }
  it { should_not be_dropdown }
  it { should_not be_radio }

  it "should pass along 0 and 1" do
    described_class.new(0).should == 0
    described_class.new(1).should == 1
  end

  it "should convert a numeric string to a number" do
    described_class.new('0').should == 0
    described_class.new('1').should == 1
  end

  it "should return 0 for a truthy value" do
    described_class.new(true).should == 0
    described_class.new(:abc).should == 0
  end

  it "should return 1 for a falsey value" do
    described_class.new(false).should == 1
    described_class.new(nil).should == 1
  end

  describe "#value" do
    it "should return true for a truthy value" do
      described_class.new(true).value.should == true
      described_class.new(:abc).value.should == true
      described_class.new(0).value.should == true
    end

    it "should return false for a falsey value" do
      described_class.new(false).value.should == false
      described_class.new(nil).value.should == false
      described_class.new(1).value.should == false
    end
  end

  describe "#!" do
    it "should return false if the boolean is true" do
      !described_class.new(true).should == false
    end

    it "should return true if the boolean is false" do

    end
  end
end

describe Compendium::DateParam do
  subject{ described_class.new(Date.today) }

  it { should_not be_scalar }
  it { should_not be_boolean }
  it { should be_date }
  it { should_not be_dropdown }
  it { should_not be_radio }

  it "should convert date strings to date objects" do
    p = described_class.new("2010-05-20")
    p.should == Date.new(2010, 5, 20)
  end

  it "should convert other date/time formats to date objects" do
    described_class.new(DateTime.new(2010, 5, 20, 10, 30, 59)) == Date.new(2010, 5, 20)
    described_class.new(Time.new(2010, 5, 20, 10, 30, 59)) == Date.new(2010, 5, 20)
    described_class.new(Date.new(2010, 5, 20)) == Date.new(2010, 5, 20)
  end
end

describe Compendium::DropdownParam do
  subject{ described_class.new(0, %w(a b c)) }

  it { should_not be_scalar }
  it { should_not be_boolean }
  it { should_not be_date }
  it { should be_dropdown }
  it { should_not be_radio }
end

describe Compendium::RadioParam do
  subject{ described_class.new(0, %w(a b c)) }

  it { should_not be_scalar }
  it { should_not be_boolean }
  it { should_not be_date }
  it { should_not be_dropdown }
  it { should be_radio }
end