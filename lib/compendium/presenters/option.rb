require 'active_support/core_ext/string/output_safety'

module Compendium
  module Presenters
    class Option < Base
      MISSING_CHOICES_ERROR = 'choices must be specified'.freeze

      presents :option
      delegate :hidden?, to: :option

      def name
        t("options.#{option.name}", cascade: { offset: 2 })
      end

      def label(form)
        return label_with_accessible_tooltip(form) if option.note? && defined?(AccessibleTooltip)

        out = ActiveSupport::SafeBuffer.new
        out << content_tag(:span, label_content(form), class: 'option-label')
        out << content_tag(:div, note_text, class: 'option-note') if option.note?
        out
      end

      def note
        return unless option.note?
        content_tag(:div, t(note_key), class: 'option-note')
      end

      def input(ctx, form)
        out = ActiveSupport::SafeBuffer.new

        raise ArgumentError, MISSING_CHOICES_ERROR if missing_choices?

        out << case option.type.to_sym
          when :scalar
            scalar_field(form)

          when :date
            date_field(form)

          when :dropdown
            dropdown_field(form, ctx)

          when :boolean, :radio
            radio_fields(form)
        end
      end

      def hidden_field(form)
        form.hidden_field option.name
      end

    private

      def note_key
        return unless option.note?
        option.note == true ? :"#{option.name}_note" : option.note
      end

      def note_text
        return unless option.note?
        t("options.#{note_key}", cascade: { offset: 2 })
      end

      def missing_choices?
        !option.choices && (option.radio? || option.dropdown?)
      end

      def date_field(form, include_time = false)
        content_tag('div', class: 'option-date') do
          if defined?(CalendarDateSelect)
            form.calendar_date_select option.name, time: include_time, popup: 'force'
          else
            form.text_field option.name
          end
        end
      end

      def scalar_field(form)
        content_tag('div', class: 'option-scalar') do
          form.text_field option.name
        end
      end

      def dropdown_field(form, ctx)
        choices = option.choices
        choices = ctx.instance_exec(&choices) if choices.respond_to?(:call)

        content_tag('div', class: 'option-dropdown') do
          form.select option.name, choices, option.options.symbolize_keys
        end
      end

      def radio_fields(form)
        choices = option.radio? ? option.choices : %w(true false)
        choices.each.with_object(ActiveSupport::SafeBuffer.new).with_index { |(choice, out), index| out << radio_button(form, choice, index) }
      end

      def radio_button(form, label, value)
        content_tag('div', class: 'option-radio') do
          div_content = ActiveSupport::SafeBuffer.new
          div_content << form.radio_button(option.name, value)
          div_content << form.label(option.name, t(label), value: value)
        end
      end

      def label_with_accessible_tooltip(form)
        title = t("options.#{option.name}_note_title", default: '', cascade: { offset: 2 })
        tooltip = accessible_tooltip(:help, label: name, title: title) { note_text }
        form.label option.name, tooltip
      end

      def label_content(form)
        case option.type.to_sym
          when :boolean, :radio
            name

          else
            form.label option.name, name
        end
      end
    end
  end
end
