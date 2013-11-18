require 'compendium/params'

describe Compendium::Params do
  let(:options) {
    opts = Collection[Compendium::Option]
    opts << Compendium::Option.new(name: :starting_on, type: :date, default: ->{ Date.today })
    opts << Compendium::Option.new(name: :ending_on, type: :date)
    opts << Compendium::Option.new(name: :report_type, type: :radio, choices: [:big, :small])
    opts << Compendium::Option.new(name: :boolean, type: :boolean)
    opts << Compendium::Option.new(name: :another_boolean, type: :boolean)
    opts
  }

  subject{ described_class.new(@params, options) }

  it "should only allow keys that are given as options" do
    @params = { starting_on: '2013-10-15', foo: :bar }
    subject.keys.should_not include :foo
  end

  it "should set missing options to their default value" do
    @params = {}
    subject.starting_on.should == Date.today
  end

  it "should set missing options to nil if there is no default value" do
    @params = {}
    subject.ending_on.should be_nil
  end

  describe "#validations" do
    subject { described_class.new({}, options) }

    before do
      described_class.validates :ending_on, presence: true
      subject.valid?
    end

    it { should_not be_valid }
    its('errors.keys') { should include :ending_on }
  end
end