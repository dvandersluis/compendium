require 'spec_helper'
require 'compendium/presenters/base'

TestPresenter = Class.new(Compendium::Presenters::Base) do
  presents :test_obj
end

describe Compendium::Presenters::Base do
  let(:template) { double("Template", delegated?: true) }
  subject { TestPresenter.new(template, :test) }

  it "should allow the object name to be overridden" do
    subject.test_obj.should == :test
  end

  it "should delegate missing methods to the template object" do
    template.should_receive(:delegated?)
    subject.should be_delegated
  end
end