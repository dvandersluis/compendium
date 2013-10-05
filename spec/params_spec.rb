require 'compendium/params'

describe Compendium::Params do
  let(:options) { {
    starting_on: Compendium::Option.new(name: :starting_on, type: :date, default: ->{ Date.today }),
    ending_on: Compendium::Option.new(name: :ending_on, type: :date),
    report_type: Compendium::Option.new(name: :report_type, type: :radio, choices: [:big, :small]),
    boolean: Compendium::Option.new(name: :boolean, type: :boolean),
    another_boolean: Compendium::Option.new(name: :another_boolean, type: :boolean)
  } }

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
end