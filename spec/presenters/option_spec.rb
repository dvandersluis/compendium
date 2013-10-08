require 'spec_helper'
require 'compendium/presenters/option'
require 'compendium/option'

describe Compendium::Presenters::Option do
  let(:template) do
    t = double('Template')
    t.stub(:t) { |key| key } # Stub I18n.t to just return the given value
    t
  end

  let(:option) { Compendium::Option.new(name: :test_option) }

  subject { described_class.new(template, option) }

  describe "#name" do
    it "should pass the name through I18n" do
      template.should_receive(:t).with(:test_option)
      subject.name
    end
  end

  describe "#note" do
    before { template.stub(:content_tag) }

    it "should return nil if no note is specified" do
      subject.note.should be_nil
    end

    it "should pass to I18n if the note option is set to true" do
      option.merge!(note: true)
      template.should_receive(:t).with(:test_option_note)
      subject.note
    end

    it "should pass to I18n if the note option is set" do
      option.merge!(note: :the_note)
      template.should_receive(:t).with(:the_note)
      subject.note
    end

    it "should create the note within a div with class option-note" do
      option.merge!(note: true)
      template.should_receive(:content_tag).with(:div, anything, class: 'option-note')
      subject.note
    end
  end
end

