require 'compendium'
require 'compendium/dsl'
require 'compendium/option'

RSpec.describe Compendium::DSL::Option do
  subject do
    Class.new do
      extend Compendium::DSL::Option
      inheritable_attr :options, default: ::Collection[Compendium::Option]
    end
  end

  describe '#option' do
    before { subject.option :starting_on, :date }

    specify { expect(subject.options).to include :starting_on }
    specify { expect(subject.options[:starting_on]).to be_date }

    it 'allows previously defined options to be redefined' do
      expect { subject.option :starting_on, :boolean }.to change { subject.options[:starting_on].type }.
        from('date').to('boolean')
    end

    it 'allows overriding default value' do
      proc = -> { Date.new(2013, 6, 1) }
      subject.option :starting_on, :date, default: proc
      expect(subject.options[:starting_on].default).to eq(proc)
    end

    it 'adds validations' do
      subject.option :foo, :scalar, validates: { presence: true }
      expect(subject.params_class.validators_on(:foo)).to_not be_empty
    end

    it 'does not add validations if no validates option is given' do
      expect(subject.params_class).to_not receive :validates
      subject.option :foo, :scalar
    end

    it 'does not bleed overridden options into the superclass' do
      r = Class.new(subject)
      r.option :starting_on, :boolean
      r.option :new, :date
      expect(subject.options[:starting_on]).to be_date
    end

    it 'requires a type be given' do
      expect { subject.option :foo }.to raise_error(ArgumentError)
    end
  end
end
