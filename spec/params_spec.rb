require 'compendium/params'

describe Compendium::Params do
  let(:options) {
    opts = Collection[Compendium::Option]
    opts << Compendium::Option.new(name: :starting_on, type: :date, default: ->{ Date.today })
    opts << Compendium::Option.new(name: :ending_on, type: :date)
    opts << Compendium::Option.new(name: :report_type, type: :radio, choices: [:big, :small])
    opts << Compendium::Option.new(name: :boolean, type: :boolean)
    opts << Compendium::Option.new(name: :another_boolean, type: :boolean)
    opts << Compendium::Option.new(name: :number, type: :scalar)
    opts
  }

  subject{ described_class.new(@params, options) }

  it "should only allow keys that are given as options" do
    @params = { starting_on: '2013-10-15', foo: :bar }
    expect(subject.keys).not_to include :foo
  end

  it "should set missing options to their default value" do
    @params = {}
    expect(subject.starting_on).to eq(Date.today)
  end

  it "should set missing options to nil if there is no default value" do
    @params = {}
    expect(subject.ending_on).to be_nil
  end

  describe "#validations" do
    let(:report_class) { Class.new(described_class) }

    context 'presence' do
      subject { report_class.new({}, options) }

      before do
        report_class.validates :ending_on, presence: true
        subject.valid?
      end

      it { is_expected.not_to be_valid }
      specify { expect(subject.errors.keys).to include :ending_on }
    end

    context 'numericality' do
      subject { report_class.new({ number: 'abcd' }, options) }
      before do
        report_class.validates :number, numericality: true
        subject.valid?
      end

      it { is_expected.not_to be_valid }
      specify { expect(subject.errors.keys).to include :number }
    end
  end
end
