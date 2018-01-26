require 'spec_helper'
require 'compendium/presenters/base'

TestPresenter = Class.new(Compendium::Presenters::Base) do
  presents :test_obj
end

describe Compendium::Presenters::Base do
  let(:template) { double('Template', delegated?: true) }
  subject { TestPresenter.new(template, :test) }

  it 'should allow the object name to be overridden' do
    expect(subject.test_obj).to eq(:test)
  end

  it 'should delegate missing methods to the template object' do
    expect(template).to receive(:delegated?)
    expect(subject).to be_delegated
  end
end
