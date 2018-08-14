require 'compendium/params'

RSpec.describe Compendium::Params do
  let(:params) { {} }
  let(:options) do
    opts = Collection[Compendium::Option]
    opts << Compendium::Option.new(name: :starting_on, type: :date, default: -> { Date.today })
    opts << Compendium::Option.new(name: :ending_on, type: :date)
    opts << Compendium::Option.new(name: :report_type, type: :radio, choices: [:big, :small])
    opts << Compendium::Option.new(name: :boolean, type: :boolean)
    opts << Compendium::Option.new(name: :another_boolean, type: :boolean)
    opts << Compendium::Option.new(name: :number, type: :scalar)
    opts
  end

  subject { described_class.new(params, options) }

  it 'only allows keys that are given as options' do
    params.merge!(starting_on: '2013-10-15', foo: :bar)
    expect(subject.keys).to_not include :foo
  end

  it 'sets missing options to their default value' do
    expect(subject.starting_on).to eq(Date.today)
  end

  it 'sets missing options to nil if there is no default value' do
    expect(subject.ending_on).to be_nil
  end

  describe '#validations' do
    let(:report_class) { Class.new(described_class) }

    context 'presence' do
      subject { report_class.new({}, options) }

      before do
        report_class.validates :ending_on, presence: true
        subject.valid?
      end

      it { is_expected.to_not be_valid }
      specify { expect(subject.errors.keys).to include :ending_on }
    end

    context 'numericality' do
      subject { report_class.new({ number: 'abcd' }, options) }

      before do
        report_class.validates :number, numericality: true
        subject.valid?
      end

      it { is_expected.to_not be_valid }
      specify { expect(subject.errors.keys).to include :number }
    end
  end
end
