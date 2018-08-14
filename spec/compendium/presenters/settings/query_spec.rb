require 'compendium/presenters/settings/query'

RSpec.describe Compendium::Presenters::Settings::Query do
  subject { described_class.new }

  describe '#update' do
    before { subject.foo = :bar }

    it 'overrides previous settings' do
      subject.update do |s|
        s.foo :quux
      end

      expect(subject.foo).to eq(:quux)
    end

    it 'allows the block parameter to be skipped' do
      subject.update do
        foo :quux
      end

      expect(subject.foo).to eq(:quux)
    end
  end
end
