require 'compendium'
require 'compendium/dsl'

RSpec.describe Compendium::DSL::Exports do
  subject do
    Class.new do
      extend Compendium::DSL::Exports
      inheritable_attr :exporters, default: {}
    end
  end

  describe '#exports' do
    it 'does not have any exporters by default' do
      expect(subject.exporters).to be_empty
    end

    it 'sets the export to true if no options are given' do
      subject.exports :csv
      expect(subject.exporters[:csv]).to eq(true)
    end

    it 'saves any given options' do
      subject.exports :csv, :main_query
      subject.exports :pdf, :foo, :bar
      expect(subject.exporters[:csv]).to eq(:main_query)
      expect(subject.exporters[:pdf]).to eq([:foo, :bar])
    end
  end
end
