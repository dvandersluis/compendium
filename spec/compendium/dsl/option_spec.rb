require 'spec_helper'
require 'compendium'
require 'compendium/dsl'
require 'compendium/option'

describe Compendium::DSL::Option do
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

    it 'should allow previously defined options to be redefined' do
      subject.option :starting_on, :boolean
      expect(subject.options[:starting_on]).to be_boolean
      expect(subject.options[:starting_on]).not_to be_date
    end

    it 'should allow overriding default value' do
      proc = -> { Date.new(2013, 6, 1) }
      subject.option :starting_on, :date, default: proc
      expect(subject.options[:starting_on].default).to eq(proc)
    end

    it 'should add validations' do
      subject.option :foo, validates: { presence: true }
      expect(subject.params_class.validators_on(:foo)).not_to be_empty
    end

    it 'should not add validations if no validates option is given' do
      expect(subject.params_class).not_to receive :validates
      subject.option :foo
    end

    it 'should not bleed overridden options into the superclass' do
      r = Class.new(subject)
      r.option :starting_on, :boolean
      r.option :new, :date
      expect(subject.options[:starting_on]).to be_date
    end
  end
end
