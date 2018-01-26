require 'spec_helper'
require 'compendium/presenters/option'
require 'compendium/option'

describe Compendium::Presenters::Option do
  let(:template) do
    t = double('Template')
    allow(t).to receive(:t) { |key| key } # Stub I18n.t to just return the given value
    t
  end

  let(:form) { double('Form') }
  let(:ctx) { double('Context') }
  let(:option) { Compendium::Option.new(name: :test_option) }

  subject { described_class.new(template, option) }

  describe '#name' do
    it 'should pass the name through I18n' do
      expect(template).to receive(:t).with('options.test_option', anything)
      subject.name
    end
  end

  describe '#note' do
    before { allow(template).to receive(:content_tag) }

    it 'should return nil if no note is specified' do
      expect(subject.note).to be_nil
    end

    it 'should pass to I18n if the note option is set to true' do
      option[:note] = true
      expect(template).to receive(:t).with(:test_option_note)
      subject.note
    end

    it 'should pass to I18n if the note option is set' do
      option[:note] = :the_note
      expect(template).to receive(:t).with(:the_note)
      subject.note
    end

    it 'should create the note within a div with class option-note' do
      option[:note] = true
      expect(template).to receive(:content_tag).with(:div, anything, class: 'option-note')
      subject.note
    end
  end

  describe '#label' do
    context 'when the option has a note' do
      before do
        allow(template).to receive(:content_tag)
        allow(form).to receive(:label) { |_field, name| name }
      end

      context 'when a note is provided' do
        before { option[:note] = :test }

        context 'when AccessibleTooltip is present' do
          before do
            stub_const('AccessibleTooltip', Object.new)
            expect(template).to receive(:accessible_tooltip).and_yield
          end

          it 'should return a label with the tooltip' do
            expect(form).to receive(:label).with(:test_option, 'options.test')
            subject.label(form)
          end
        end

        it 'should translate the note' do
          expect(template).to receive(:t).with('options.test', anything)
          subject.label(form)
        end

        it 'should translate the option name if no specific note is given' do
          option[:note] = true
          expect(template).to receive(:t).with('options.test_option_note', anything)
          subject.label(form)
        end

        it 'should render the note' do
          expect(template).to receive(:content_tag).with(:div, 'options.test', class: 'option-note')
          subject.label(form)
        end
      end

      it 'should render the label' do
        expect(template).to receive(:content_tag).with(:span, 'options.test_option', class: 'option-label')
        subject.label(form)
      end
    end
  end

  describe '#input' do
    before do
      allow(template).to receive(:content_tag).and_yield

      option.options = { foo: :bar }
      option.choices = [1, 2, 3]
    end

    context 'with a scalar option' do
      before { option.type = :scalar }

      it 'should render an text field' do
        expect(form).to receive(:text_field).with(:test_option)
        subject.input(ctx, form)
      end
    end

    context 'with a date option' do
      before { option.type = :date }

      it 'should render a text field' do
        expect(form).to receive(:text_field).with(:test_option)
        subject.input(ctx, form)
      end

      it 'should render a calendar date select if defined' do
        stub_const('CalendarDateSelect', Object.new)
        expect(form).to receive(:calendar_date_select).with(:test_option, anything)
        subject.input(ctx, form)
      end
    end

    context 'with a dropdown option' do
      before { option.type = :dropdown }

      it 'should render a select field' do
        expect(form).to receive(:select).with(:test_option, [1, 2, 3], { foo: :bar })
        subject.input(ctx, form)
      end

      it 'should raise if there are no choices' do
        option.choices = nil
        expect { subject.input(ctx, form) }.to raise_error ArgumentError
      end
    end

    context 'with a boolean option' do
      before { option.type = :boolean }

      it 'should render radio buttons and labels for true and false' do
        expect(form).to receive(:radio_button).with(:test_option, 0)
        expect(form).to receive(:label).with(:test_option, 'true', value: 0)
        expect(form).to receive(:radio_button).with(:test_option, 1)
        expect(form).to receive(:label).with(:test_option, 'false', value: 1)
        subject.input(ctx, form)
      end
    end

    context 'with a radio option' do
      before { option.type = :radio }

      it 'should render radio buttons and labels for each option' do
        expect(form).to receive(:radio_button).with(:test_option, 0)
        expect(form).to receive(:label).with(:test_option, 1, value: 0)
        expect(form).to receive(:radio_button).with(:test_option, 1)
        expect(form).to receive(:label).with(:test_option, 2, value: 1)
        expect(form).to receive(:radio_button).with(:test_option, 2)
        expect(form).to receive(:label).with(:test_option, 3, value: 2)
        subject.input(ctx, form)
      end

      it 'should raise if there are no choices' do
        option.choices = nil
        expect { subject.input(ctx, form) }.to raise_error ArgumentError
      end
    end
  end
end
