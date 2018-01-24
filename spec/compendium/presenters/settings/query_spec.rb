require 'spec_helper'
require 'compendium/presenters/settings/query'

describe Compendium::Presenters::Settings::Query do
  subject { described_class.new }

  describe '#update' do
    before { subject.foo = :bar }

    it 'should override previous settings' do
      subject.update do |s|
        s.foo :quux
      end

      expect(subject.foo).to eq(:quux)
    end

    it 'should allow the block parameter to be skipped' do
      subject.update do
        foo :quux
      end

      expect(subject.foo).to eq(:quux)
    end
  end
end
