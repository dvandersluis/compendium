module Compendium
  module Presenters
    class Option < Base
      MISSING_CHOICES_ERROR = "choices must be specified"

      presents :option
      delegate :hidden?, to: :option

      def name
        t("options.#{option.name}", cascade: { offset: 2 })
      end

      def label(form)
        if option.note?
          key = option.note == true ? :"#{option.name}_note" : option.note
          note = t("options.#{key}", cascade: { offset: 2 })
        end

        if option.note? && defined?(AccessibleTooltip)
          title = t("options.#{option.name}_note_title", default: '', cascade: { offset: 2 })
          tooltip = accessible_tooltip(:help, label: name, title: title) { note }
          return form.label option.name, tooltip
        else
          label = case option.type.to_sym
            when :boolean, :radio
              name

            else
              form.label option.name, name
          end

          out = ActiveSupport::SafeBuffer.new
          out << content_tag(:span, label, class: 'option-label')
          out << content_tag(:div, note, class: 'option-note') if option.note?
          out
        end
      end

      def note
        if option.note?
          key = option.note === true ? :"#{option.name}_note" : option.note
          content_tag(:div, t(key), class: 'option-note')
        end
      end

      def input(ctx, form)
        out = ActiveSupport::SafeBuffer.new

        case option.type.to_sym
          when :scalar
            out << scalar_field(form)

          when :date
            out << date_field(form)

          when :dropdown
            raise ArgumentError, MISSING_CHOICES_ERROR unless option.choices

            choices = option.choices
            choices = ctx.instance_exec(&choices) if choices.respond_to?(:call)
            out << dropdown(form, choices, option.options)

          when :boolean, :radio
            choices = if option.radio?
              raise ArgumentError, MISSING_CHOICES_ERROR unless option.choices
              option.choices
            else
              %w(true false)
            end

            choices.each.with_index { |choice, index| out << radio_button(form, choice, index) }
        end

        out
      end

      def hidden_field(form)
        form.hidden_field option.name
      end

    private

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

      def dropdown(form, choices = {}, options = {})
        content_tag('div', class: 'option-dropdown') do
          form.select option.name, choices, options.symbolize_keys
        end
      end

      def radio_button(form, label, value)
        content_tag('div', class: 'option-radio') do
          div_content = ActiveSupport::SafeBuffer.new
          div_content << form.radio_button(option.name, value)
          div_content << form.label(option.name, t(label), value: value)
        end
      end
    end
  end
end
