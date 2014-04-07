require 'spec_helper'
require 'compendium/presenters/chart'

describe Compendium::Presenters::Chart do
  let(:template) { double('Template', protect_against_forgery?: false, request_forgery_protection_token: :authenticity_token, form_authenticity_token: "ABCDEFGHIJ").as_null_object }
  let(:query) { double('Query', name: 'test_query', results: results, ran?: true, options: {}).as_null_object }
  let(:results) { Compendium::ResultSet.new([]) }

  before do
    described_class.any_instance.stub(:provider) { double('ChartProvider') }
    described_class.any_instance.stub(:initialize_chart_provider)
  end

  describe '#initialize' do
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

    context "when the query has not been run" do
      before { query.stub(ran?: false, url: '/path/to/query.json') }

      subject{ described_class.new(template, query, :pie, params: { foo: 'bar' }) }

      its(:data) { should == '/path/to/query.json' }
      its(:params) { should == { report: { foo: 'bar' } } }

      context "when CSRF protection is enabled" do
        before { template.stub(protect_against_forgery?: true) }

        its(:params) { should include authenticity_token: "ABCDEFGHIJ" }
      end

      context "when CSRF protection is disabled" do
        its(:params) { should_not include authenticity_token: "ABCDEFGHIJ" }
      end
    end
  end

  describe '#remote?' do
    it 'should be true if options[:remote] is set to true' do
      described_class.new(template, query, :pie, remote: true).should be_remote
    end

    it 'should be true if the query has not been run yet' do
      query.stub(run?: false)
      described_class.new(template, query, :pie).should_be_remote
    end

    it 'should be false otherwise' do
      described_class.new(template, query, :pie).should_not be_remote
    end
  end
end