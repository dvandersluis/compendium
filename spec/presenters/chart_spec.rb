require 'spec_helper'
require 'compendium/presenters/chart'

describe Compendium::Presenters::Chart do
  before do
    described_class.any_instance.stub(:provider) { double('ChartProvider') }
    described_class.any_instance.stub(:initialize_chart_provider)
  end

  describe '#initialize' do
    let(:template) { double('Template') }
    let(:query) { double('Query', name: 'test_query', results: results, options: {}) }
    let(:results) { Compendium::ResultSet.new([]) }

    context 'when all params are given' do
      subject{ described_class.new(template, query, :pie, :container) }

      its(:data) { should == results.records }
      its(:container) { should == :container }
    end

    context 'when container is not given' do
      subject{ described_class.new(template, query, :pie) }

      its(:data) { should == results.records }
      its(:container) { should == 'test_query' }
    end

    context "when options are given" do
      before { results.stub(:records) { { one: [] } } }
      subject{ described_class.new(template, query, :pie, index: :one) }

      its(:data) { should == results.records[:one] }
      its(:container) { should == 'test_query' }
    end
  end
end